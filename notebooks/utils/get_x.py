import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer


def get_x(df):
    vectorizer_ast = CountVectorizer(ngram_range=(1, 4), analyzer='word')
    ast_vectorized = vectorizer_ast.fit_transform(
        df['astContextBasic'])

    vectorizer_mutation_op = CountVectorizer()
    mutation_op_vectorized = vectorizer_mutation_op.fit_transform(
        df['mutationOperator'])

    vectorizer_node_type = CountVectorizer()
    node_type_vectorized = vectorizer_node_type.fit_transform(
        df['nodeTypeBasic'])

    ast_df = pd.DataFrame(
        ast_vectorized.A,
        columns=vectorizer_ast.get_feature_names())

    mutation_op_df = pd.DataFrame(
        mutation_op_vectorized.A,
        columns=vectorizer_mutation_op.get_feature_names())

    node_type_df = pd.DataFrame(
        node_type_vectorized.A,
        columns=vectorizer_node_type.get_feature_names())

    x = df.iloc[:, 4:7]
    x = x.join(ast_df.add_prefix('ast_'))
    x = x.join(mutation_op_df.add_prefix('mop_'))
    x = x.join(node_type_df.add_prefix('nty_'))

    return x