function probabilidade_contingencia = contingencia_mais_provavel(sistema)

qtd_linhas = size(sistema.taxa_falha);
probabilidade_contingencia = [[]];

for m = 1:qtd_linhas
    probabilidade_contingencia(m,1) = sistema.taxa_falha(m,2);
    probabilidade_contingencia(m,2) = sistema.taxa_falha(m,3);
    probabilidade_contingencia(m,3) = (1 - (sistema.taxa_falha(m,4)/8760)) * 100;
end

probabilidade_contingencia = sortrows(probabilidade_contingencia,3);