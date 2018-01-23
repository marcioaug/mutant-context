import pandas as pd

DATA_DIR = 'data'
MUTANTS_CONTEXT = '{0}/{1}/mutants.context'
KILL_CSV = '{0}/{1}/kill.csv'


def get_subject(subject):

    mutants_context_df = pd.read_csv(MUTANTS_CONTEXT.format(DATA_DIR, subject))
    kill_df = pd.read_csv(KILL_CSV.format(DATA_DIR, subject))

    del mutants_context_df['mutationOperatorGroup']
    del mutants_context_df['nodeTypeDetailed']
    del mutants_context_df['nodeContextBasic']
    del mutants_context_df['astContextDetailed']
    del mutants_context_df['parentContextBasic']
    del mutants_context_df['parentContextDetailed']
    del mutants_context_df['parentStmtContextBasic']
    del mutants_context_df['parentStmtContextDetailed']

    kill = []

    for i in mutants_context_df['mutantNo']:

        search = kill_df.query('MutantNo == %d' % i)

        if len(search) > 0:
            kill.append(search.iloc[0, 1])
        else:
            kill.append(None)

    mutants_context_df['kill'] = kill

    return mutants_context_df.dropna(axis=0, how='any').reset_index(drop=True)


def get_subjects(subjects):
    mutant_context_df = None

    for subject in subjects:
        if mutant_context_df is not None:
            mutant_context_df = mutant_context_df.append(
                get_subject(subject))
        else:
            mutant_context_df = get_subject(subject)

    return mutant_context_df.reset_index(drop=True)

