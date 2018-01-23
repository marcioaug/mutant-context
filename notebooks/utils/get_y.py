def get_y(df, column):
    status_to_nonequivalent = {
        'FAIL': 'NON_EQUIVALENT',
        'TIME': 'NON_EQUIVALENT',
        'EXC': 'NON_EQUIVALENT',
        'LIVE': 'MAYBE_EQUIVALENT'
    }

    status_to_trivial = {
        'FAIL': 'NON_TRIVIAL',
        'TIME': 'NON_TRIVIAL',
        'EXC': 'TRIVIAL',
        'LIVE': 'NON_TRIVIAL'
    }

    df['non_equivalent'] = df['kill'].str.upper().map(status_to_nonequivalent)
    df['trivial'] = df['kill'].str.upper().map(status_to_trivial)

    return df[column]