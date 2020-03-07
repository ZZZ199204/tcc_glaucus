function cenarios(qtd_barras)
clc
fprintf('Informe o cenário desejado: \n');
fprintf('[1] FPO inicial sem compensação de reativos, com limites de linhas ignorados\n');
fprintf('[2] FPO inicial sem compensação de reativos, considerando limites de fluxo nas linhas\n');
fprintf('[3] FPO com alocação de TCSC\n');
fprintf('[0] Voltar\n')
opcao = input('-> ');
while opcao ~= 0
    switch opcao
        case 1
            if qtd_barras == 6
                sistema = sistema6_caso1correto;
            elseif qtd_barras == 14
                sistema = sistema14_caso1correto;
            elseif qtd_barras == 30
                sistema = sistema30_caso1correto;
            elseif qtd_barras == 118
                sistema = sistema118_caso1correto;
            end
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados = runopf(sistema,configurar);
            clc
            printpf_caso1(resultados)
            fprintf('\nPressione enter para continuar...\n');
            pause
        case 2
            if qtd_barras == 6
                sistema = sistema6_caso2correto;
            elseif qtd_barras == 14
                sistema = sistema14_caso2correto;
            elseif qtd_barras == 30
                sistema = sistema30_caso2correto;
            elseif qtd_barras == 118
                sistema = sistema118_caso2correto;
            end
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados = runopf(sistema,configurar);
            clc
            printpf_caso2(resultados)
            fprintf('\nPressione enter para continuar...\n');
            pause
        case 3
            if qtd_barras == 6
                sistema = sistema6_caso2correto;
            elseif qtd_barras == 14
                sistema = sistema14_caso2correto;
            elseif qtd_barras == 30
                sistema = sistema30_caso2correto;
            elseif qtd_barras == 118
                sistema = sistema118_caso2correto;
            end
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados = runopf(sistema,configurar);
            clc
            printpf_caso2(resultados);
            fprintf('\nPressione enter para continuar...\n');
            pause
            [corte,t,s] = corte_minimo(sistema)
            sobrecar = sobrecarga(resultados);
            gargalos = verifica_gargalos(corte,sobrecar,t,s)
            pause
            tam_gargalos = size(gargalos);
            if tam_gargalos(1) == 0
                clc
                fprintf('\nO corte m�nimo n�o pode ser aplicado para este caso!!!')
                fprintf('\nTodas as linhas vizinhas aos gargalos ser�o analisadas!!!')
                fprintf('\nPressione enter para continuar...\n');
                pause
                gargalos = linhas_vizinhas_gargalo(sobrecar,sistema);
            end
            [garg,valor,taxa,result_otimo,garg_otimo,sistema_otimo] = otimo(sistema,gargalos,configurar);
            resultados = runopf(sistema_otimo,configurar);
            imprime_result(garg,valor,taxa,garg_otimo);
            fprintf('\nPressione enter para continuar...\n');
            pause
            clc
            printpf_caso2(result_otimo);
            fprintf('\nPressione enter para continuar...\n');
            pause
        otherwise
            clc
            fprintf('ERRO: Opção inválida!!!\n');
            fprintf('Pressione enter para continuar...\n')
            pause
    end
    clc
    fprintf('Informe o cenário desejado: \n');
    fprintf('[1] FPO inicial sem compensação de reativos, com limites de linhas ignorados\n');
    fprintf('[2] FPO inicial sem compensação de reativos, considerando limites de fluxo nas linhas\n');
    fprintf('[3] FPO com alocação de TCSC\n');
    fprintf('[0] Voltar\n')
    opcao = input('-> ');
end
end