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
    df = pd.read_csv(path, header=None, usecols=[0, 1],
                     dtype={'filepath': str, 'state': str})

    res = dict()
    for path, state in df.itertuples(index=False):
        path: str
        state: str
        res[path] = State(state.strip())
    return res


def is_empty(path: 'Path') -> bool:
    assert path.is_dir(), f"Called is_empty() on {path} which is not a directory"
    return next(path.iterdir(), None) is None


def prompt_for_proceed(prompt: str) -> bool:
    while True:
        res = input(f'{prompt} (y/n) ').lower()
        if res in ('y', 'yes', 'oui'):
            return True
        elif res in ('n', 'no', 'non'):
            return False
        else:
            print(f'Invalid response {res}.')


def run_directives(src_dir: 'Path', dst_dir: 'Path', directives: 'dict[Path, str]', default_state: 'State | None'):
    copied = 0

    sorted: 'dict[State, set[str]]' = {
        State.kept: set(),
        State.deleted: set(),
        State.unspecified: set(),
    }

    for relative, directive in directives.items():
        if directive == State.unspecified:
            if default_state is None:
                delete = prompt_for_proceed('Delete undecided musics?')
                default_state = State.deleted if delete else State.kept
            action = default_state
        else:
            action = directive

        sorted[directive].add(relative)

        path = src_dir / relative
        dest = dst_dir / relative
        if action == State.kept:
            if path.exists():
                copied += 1
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(path, dest)
            else:
                logging.error('File at %s does not exist', path)

    logging.info('%s out of %s copied', copied, len(directives))
    dropped = sorted[State.deleted]
    if default_state == State.deleted:
        dropped |= sorted[State.unspecified]

    if dropped:
        print('The following files will be deleted:')
        for p in dropped:
            print(f"- {p}")

        proceed = prompt_for_proceed('Continue?')
        if proceed:
            for relative in directives.keys():
                p = src_dir / relative
                p.unlink(missing_ok=True)
                try:
                    p = p.parent
                    while p != src_dir and is_empty(p):
                        p.rmdir()
                        p = p.parent
                except Exception as e:
                    logging.error(f'Could not remove empty folder {p} : {e}')
        else:
            print('Original musics were kept as well')


def setup_parser() -> 'ap.ArgumentParser':
    parser = ap.ArgumentParser()

    parser.add_argument('directives_path', type=Path)

    parser.add_argument('src_dir', type=Path)
    parser.add_argument('dst_dir', type=Path)

    parser.add_argument('--default_state', type=State, choices=[State.kept, State.deleted], default=None,
                        help="State to fallback on when left on 'unspecified'. "
                        "Defaults to 'None' in which case the user will be prompted to choose between 'kept' and 'deleted'")

    return parser


if __name__ == '__main__':
    parser = setup_parser()
    args = parser.parse_args()

    directives = read_directives(args.directives_path)

    run_directives(args.src_dir, args.dst_dir, directives,
                   default_state=args.default_state)
