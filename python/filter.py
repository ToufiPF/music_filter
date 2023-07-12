#!python3
import argparse as ap
import pandas as pd
import shutil
import logging
from pathlib import Path
from enum import StrEnum, auto


class State(StrEnum):
    unspecified = auto()
    kept = auto()
    deleted = auto()


def read_directives(path: 'Path') -> 'dict[str, State]':
    df = pd.read_csv(path, header=None, usecols=[0, 1], dtype={'filepath': str, 'state': str})

    res = dict()
    for path, state in df.itertuples(index=False):
        path: str
        state: str
        res[path] = State(state.strip())
    return res



def prompt_for_proceed() -> bool:
    while True:
        res = input('Continue ? (y/n) ').lower()
        if res in ('y', 'yes', 'oui'):
            return True
        elif res in ('n', 'no', 'non'):
            return False
        else:
            print(f'Invalid response {res}.')


def run_directives(input_dir: 'Path', output_dir: 'Path', directives: 'dict[Path, str]', default_state: State):
    copied = 0
    dropped: 'set[Path]' = set()
    for relative, state in directives.items():
        if state == State.unspecified:
            state = default_state

        if state == State.kept:
            path = input_dir / relative
            dest = output_dir / relative
            if path.exists():
                copied += 1
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(path, output_dir)
            else:
                logging.error('File at %s does not exist', path)
        else:
            dropped += path

    logging.info('%s out of %s copied', copied, len(directives))
    if dropped:
        print('The following files will be deleted:')
        for p in dropped:
            print(f"- {p.as_posix()}")

        proceed = prompt_for_proceed()
        if proceed:
            for relative in directives.keys():
                p = input_dir / relative
                p.unlink(missing_ok=True)
                while p != input_dir and next(p.parent.iterdir(), None) is None:
                    p = p.parent
                    try:
                        p.rmdir()
                    except Exception as e:
                        logging.error(f'Could not remove empty folder {p} : {e}')
        else:
            print('Original musics were kept as well')


def setup_parser() -> 'ap.ArgumentParser':
    parser = ap.ArgumentParser()

    parser.add_argument('directives_path', type=Path)

    parser.add_argument('music_input_dir', type=Path)
    parser.add_argument('music_output_dir', type=Path)

    parser.add_argument('--default_state', type=State, choices=[State.kept, State.deleted], default=State.kept, 
                        help="State to fallback on when left on 'unspecified'. Defaults to 'kept'")

    return parser


if __name__ == '__main__':
    parser = setup_parser()
    args = parser.parse_args()

    directives = read_directives(args.directives_path)

    run_directives(args.music_input_dir, args.music_output_dir,
                   directives, default_state=args.default_state)