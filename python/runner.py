import argparse as ap
import pandas as pd
import shutil
import logging
from pathlib import Path


def read_directives(path: 'Path') -> 'pd.DataFrame':
    return pd.read_csv(path, header=0, usecols=[0,1], dtype={'filepath': str, 'kept': bool})

def prompt_for_proceed() -> bool:
    while True:
        res = input('Continue ? (y/n) ').lower()
        if res in ('y', 'yes', 'oui'):
            return True
        elif res in ('n', 'no', 'non'):
            return False
        else:
            print(f'Invalid response {res}.')


def run_directives(input_dir: 'Path', output_dir: 'Path', directives: 'pd.DataFrame'):
    copied = 0
    dropped = 0
    for filepath, kept in directives.itertuples(index=False):
        if kept:
            path = Path(filepath)
            if path.exists():
                copied += 1 
                shutil.copy(path, output_dir)
            else:
                logging.error('File at %s does not exist', path)
        else:
            dropped += 1

    logging.info('%s out of %s copied', copied, len(directives))

    if dropped != 0:
        print('The following files will be deleted:')

        proceed = prompt_for_proceed()
        if proceed:
            shutil.rmtree(input_dir)
        else:
            print('Original musics were kept as well')
            

def setup_parser() -> 'ap.ArgumentParser':
    parser = ap.ArgumentParser()

    parser.add_argument('directives_path', type=Path)

    return parser


if __name__ == '__main__':
    parser = setup_parser()
    args = parser.parse_args()

    directives = read_directives(args.directives_path)

