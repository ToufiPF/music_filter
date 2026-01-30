#!python3
import argparse as ap
import logging
import os
import pandas as pd
import stat
import shutil
from pathlib import Path
from enum import StrEnum, auto

logging.basicConfig(level=logging.DEBUG, format='[%(asctime)s] [%(levelname)s] - %(message)s')

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
    """ Returns whether the given path is a directory containing only non-music files (e.g. album covers). """
    assert path.is_dir(), f"Called is_empty() on {path} which is not a directory"
    music_extensions = set(('.mp3', '.flac', '.wav', '.ogg', '.m4a'))

    return all(f.is_file() and not f.suffix.lower() in music_extensions for f in path.iterdir())

def on_rmtree_error(func, path, exc_info):
    try:
        os.chmod(path, stat.S_IWRITE)
        func(path)
    except Exception as e:
        logging.error(f'Could not remove {path} : {e}')


def prompt_for_proceed(prompt: str) -> bool:
    while True:
        res = input(f'{prompt} (y/n) ').lower()
        if res in ('y', 'yes', 'oui'):
            return True
        elif res in ('n', 'no', 'non'):
            return False
        else:
            logging.warn(f'Invalid response {res}.')


def save_music(src_dir: 'Path', dst_dir: 'Path', music: 'str'):
    path = src_dir / music
    dest = dst_dir / music

    if path.exists():
        path.chmod(stat.S_IWRITE)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(path, dest)
        delete_music(src_dir, music)
        return True
    else:
        logging.error('File at %s does not exist - could not be saved', path)
        return False


def delete_music(src_dir: 'Path', music: 'str'):
    p = src_dir / music
    p.unlink(missing_ok=True)
    try:
        p = p.parent
        while p != src_dir and p.exists() and is_empty(p):
            p.chmod(stat.S_IWRITE)
            shutil.rmtree(p, onerror=on_rmtree_error)
            p = p.parent
    except Exception as e:
        logging.error(f'Could not remove empty folder {p} : {e}')


def run_directives(src_dir: 'Path', dst_dir: 'Path', directives: 'dict[str, State]', default_state: 'State | None'):
    sorted: 'dict[State, set[str]]' = {
        State.kept: set(),
        State.deleted: set(),
        State.unspecified: set(),
    }

    for relative, directive in directives.items():
        sorted[directive].add(relative)

    kept = sorted[State.kept]
    dropped = sorted[State.deleted]
    if sorted[State.unspecified]:
        logging.info('The following musics have a undecided state :')
        for m in sorted[State.unspecified]:
            logging.info(f' - {m}')
        if prompt_for_proceed('Delete undecided musics?'):
            dropped |= sorted[State.unspecified]

    logging.info('%s out of %s will be saved in destination folder', len(kept), len(directives))
    logging.info('%s out of %s will be deleted', len(dropped), len(directives))
    logging.info('%s out of %s will be kept in source folder', len(directives) - len(kept) - len(dropped), len(directives))

    for m in kept:
        save_music(src_dir, dst_dir, m)

    if dropped:
        logging.info('The following files will be deleted:')
        for m in dropped:
            logging.info(f"- {m}")

        proceed = prompt_for_proceed('Continue?')
        if proceed:
            for m in dropped:
                delete_music(src_dir, m)
        else:
            logging.info('Musics marked as deleted were kept in source folder')


def setup_parser() -> 'ap.ArgumentParser':
    parser = ap.ArgumentParser()

    parser.add_argument('directives_path', type=Path)

    parser.add_argument('src_dir', type=Path)
    parser.add_argument('dst_dir', type=Path)

    parser.add_argument('--default_state', type=State, choices=[State.kept, State.deleted], default=None,
                        help="State to fallback on when left on 'unspecified'. "
                        "Defaults to 'None' in which case the user will be prompted to choose between 'kept' and 'deleted'")

    parser.add_argument('--keep_directives', action='store_true',
                        help='Whether to keep directives file when done filtering')
    parser.add_argument('--delete_directives', action='store_true',
                        help='Whether to delete directives file when done filtering')

    return parser


if __name__ == '__main__':
    parser = setup_parser()
    args = parser.parse_args()

    logging.debug('Reading directing files...')
    directives = read_directives(args.directives_path)

    logging.debug('Executing directives...')
    run_directives(args.src_dir, args.dst_dir, directives,
                   default_state=args.default_state)

    if args.keep_directives:
        delete = False
    elif args.delete_directives:
        delete = True
    else:
        delete = prompt_for_proceed(
            f'Remove directives file ({args.directives_path})?')

    if delete:
        args.directives_path.unlink(missing_ok=True)
