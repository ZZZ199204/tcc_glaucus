function cenarios(qtd_barras)
clc
fprintf('Informe o cenario desejado: \n');
fprintf('[1] FPO inicial sem compensacao de reativos, com limites de linhas ignorados\n');
fprintf('[2] FPO inicial sem compensacao de reativos, considerando limites de fluxo nas linhas\n');
fprintf('[3] FPO com alocacao de TCSC\n');
fprintf('[4] Introducao da contingencia mais severa\n');
fprintf('[5] Introducao da contingencia mais provavel\n');
fprintf('[0] Voltar\n')
opcao = input('-> ');
while opcao ~= 0
    switch opcao
        case 1
            if qtd_barras == 6
                sistema1 = sistema6_caso1correto;
                sistema2 = sistema6_caso2correto;
            elseif qtd_barras == 14
                sistema1 = sistema14_caso1correto;
                sistema2 = sistema14_caso2correto;
            elseif qtd_barras == 30
                sistema1 = sistema30_caso1correto;
                sistema2 = sistema30_caso2correto;
            elseif qtd_barras == 118
                sistema1 = sistema118_caso1correto;
                sistema2 = sistema118_caso2correto;
            end
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados1 = runopf(sistema1,configurar);
            clc
            printpf_caso1(resultados1);
            fprintf('\nPressione enter para continuar...\n');
            sobrecarga = sobrecarga_2(resultados1,sistema2);
            imprime_sobrecarga_2(sobrecarga);
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
            printpf_caso2(resultados);
            sobrecar = sobrecarga_2(resultados,sistema);
            imprime_sobrecarga(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
        case 3
            if qtd_barras == 6
                sistema1 = sistema6_caso1correto;
                sistema2 = sistema6_caso2correto;
            elseif qtd_barras == 14
                sistema1 = sistema14_caso1correto;
                sistema2 = sistema14_caso2correto;
            elseif qtd_barras == 30
                sistema1 = sistema30_caso1correto;
                sistema2 = sistema30_caso2correto;
            elseif qtd_barras == 118
                sistema1 = sistema118_caso1correto;
                sistema2 = sistema118_caso2correto;
            end
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados1 = runopf(sistema1,configurar);
            clc
            printpf_caso1(resultados1);
            sobrecar = sobrecarga_2(resultados1,sistema2);
            imprime_sobrecarga_2(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
            clc
            [corte,t,s] = corte_minimo(sistema2);
            clc
            imprime_corte(corte);
            fprintf('\nPressione enter para continuar...\n');
            pause
            gargalos = verifica_gargalos(corte,sobrecar,t,s);
            tam_gargalos = size(gargalos);
            if tam_gargalos(1) == 0
                clc
                fprintf('\nO corte minimo nao pode ser aplicado para este caso!!!')
                fprintf('\nTodas as linhas vizinhas aos gargalos serao analisadas!!!')
                fprintf('\nPressione enter para continuar...\n');
                pause
                gargalos = linhas_vizinhas_gargalo(sobrecar,sistema1);
            end
            [garg,valor,taxa,taxa_otima,result_otimo,garg_otimo,sistema_otimo] = otimo(sistema1,gargalos,configurar,sistema2);
            resultados = runopf(sistema_otimo,configurar);
            imprime_result(garg,valor,taxa,garg_otimo);
            fprintf('\nPressione enter para continuar...\n');
            pause
            clc
            printpf_caso2(resultados);
            sobrecar = sobrecarga_2(resultados,sistema2);
            imprime_sobrecarga_2(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
        case 4
            if qtd_barras == 6
                sistema1 = sistema6_caso1correto;
                sistema2 = sistema6_caso2correto;
            elseif qtd_barras == 14
                sistema1 = sistema14_caso1correto;
                sistema2 = sistema14_caso2correto;
            elseif qtd_barras == 30
                sistema1 = sistema30_caso1correto;
                sistema2 = sistema30_caso2correto;
            elseif qtd_barras == 118
                sistema1 = sistema118_caso1correto;
                sistema2 = sistema118_caso2correto;
            end
            
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados = runopf(sistema1,configurar);
            sobrecar = sobrecarga_2(resultados, sistema2);
            pi_hibrido_normalizado = contingencia(sistema2)
            qtd_linhas_sistema = size(sistema1.branch);
            tam_pi = size(pi_hibrido_normalizado);
            tam_sobrecar = size(sobrecar);
            indice_pi = 1;
            sair = 0;

            for m = 1:tam_pi
                sair = 1;
                for n = 1:tam_sobrecar
                    if pi_hibrido_normalizado(m,1) == sobrecar(n,1) && pi_hibrido_normalizado(m,2) == sobrecar(n,2)
                        sair = 0;
                        indice_pi = indice_pi+1;
                        break
                    end
                end
                if sair == 1
                    break
                end
            end            
            sair = 0;
            while sair ~= 1
                for m = 1:qtd_linhas_sistema
                    if sistema1.branch(m,1) == pi_hibrido_normalizado(indice_pi,1) && sistema1.branch(m,2) == pi_hibrido_normalizado(indice_pi,2)
                        sistema1.branch(m,11) = 0;
                    end
                end
                
                
                configurar = mpoption('pf.alg','NR','verbose',3);
                resultados = runopf(sistema1,configurar);
                sobrecar = sobrecarga_2(resultados,sistema2);
                tam_sobrecar = size(sobrecar);
                
                if resultados.success == 0 || tam_sobrecar(1) == 0
                    for m = 1:qtd_linhas_sistema
                        if sistema1.branch(m,1) == pi_hibrido_normalizado(indice_pi,1) && sistema1.branch(m,2) == pi_hibrido_normalizado(indice_pi,2)
                            sistema1.branch(m,11) = 1;
                        elseif sistema1.branch(m,1) == pi_hibrido_normalizado(indice_pi+1,1) && sistema1.branch(m,2) == pi_hibrido_normalizado(indice_pi+1,2)
                            sistema1.branch(m,11) = 0;
                        end
                    end
                    indice_pi = indice_pi + 1;
                else
                    sair = 1;
                end
            end
            clc
            fprintf('====================================================\n');
            fprintf('        SISTEMA COM ANALISE DE CONTINGENCIA\n')
            fprintf('====================================================\n\n\n');
            printpf_caso2(resultados);
            sobrecar = sobrecarga_2(resultados, sistema2);
            imprime_sobrecarga(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
       
            [corte,t,s] = corte_minimo(sistema2);
            clc
            imprime_corte(corte);
            fprintf('\nPressione enter para continuar...\n');
            pause
            sobrecar = sobrecarga_2(resultados,sistema2);
            gargalos = verifica_gargalos(corte,sobrecar,t,s);
            tam_gargalos = size(gargalos);
            if tam_gargalos(1) == 0
                gargalos = linhas_vizinhas_gargalo(sobrecar,sistema1);
            end

            [garg,valor,taxa,taxa_otima,result_otimo,garg_otimo,sistema_otimo] = otimo(sistema1,gargalos,configurar,sistema2);
            clc
            imprime_result(garg,valor,taxa,garg_otimo);
            fprintf('\nPressione enter para continuar...\n');
            pause
            
            resultados = runopf(sistema_otimo,configurar);
            clc
            fprintf('============================================================\n');
            fprintf('   SISTEMA COM ANALISE DE CONTIGENCIA E ALOCACAO DO TCSC\n')
            fprintf('============================================================\n\n\n');
            printpf_caso2(resultados);
            sobrecar = sobrecarga_2(resultados,sistema2);
            imprime_sobrecarga(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
        case 5
            if qtd_barras == 6
                sistema1 = sistema6_caso1correto;
                sistema2 = sistema6_caso2correto;
            elseif qtd_barras == 14
                sistema1 = sistema14_caso1correto;
                sistema2 = sistema14_caso2correto;
            elseif qtd_barras == 30
                sistema1 = sistema30_caso1correto;
                sistema2 = sistema30_caso2correto;
            elseif qtd_barras == 118
                sistema1 = sistema118_caso1correto;
                sistema2 = sistema118_caso2correto;
            end
            
            configurar = mpoption('pf.alg','NR','verbose',3);
            resultados = runopf(sistema1,configurar);
            sobrecar = sobrecarga_2(resultados,sistema2);
            probabilidade_contingencia = contingencia_mais_provavel(sistema1);
            qtd_linhas_sistema = size(sistema1.branch);
            tam_pi = size(probabilidade_contingencia);
            tam_sobrecar = size(sobrecar);
            indice_pi = 1;
            sair = 0;

            for m = 1:tam_pi
                sair = 1;
                for n = 1:tam_sobrecar
                    if probabilidade_contingencia(m,1) == sobrecar(n,1) && probabilidade_contingencia(m,2) == sobrecar(n,2)
                        sair = 0;
                        indice_pi = indice_pi+1;
                        break
                    end
                end
                if sair == 1
                    break
                end
            end            
            sair = 0;
            while sair ~= 1
                for m = 1:qtd_linhas_sistema
                    if sistema1.branch(m,1) == probabilidade_contingencia(indice_pi,1) && sistema1.branch(m,2) == probabilidade_contingencia(indice_pi,2)
                        sistema1.branch(m,11) = 0;
                    end
                end
                
                
                configurar = mpoption('pf.alg','NR','verbose',3);
                resultados = runopf(sistema1,configurar);
                sobrecar = sobrecarga_2(resultados,sistema2);
                tam_sobrecar = size(sobrecar);
                
                if resultados.success == 0 || tam_sobrecar(1) == 0
                    for m = 1:qtd_linhas_sistema
                        if sistema1.branch(m,1) == probabilidade_contingencia(indice_pi,1) && sistema1.branch(m,2) == probabilidade_contingencia(indice_pi,2)
                            sistema1.branch(m,11) = 1;
                        elseif sistema1.branch(m,1) == probabilidade_contingencia(indice_pi+1,1) && sistema1.branch(m,2) == probabilidade_contingencia(indice_pi+1,2)
                            sistema1.branch(m,11) = 0;
                        end
                    end
                    indice_pi = indice_pi + 1;
                else
                    sair = 1;
                end
            end
            clc
            fprintf('====================================================\n');
            fprintf('        SISTEMA COM ANALISE DE CONTINGENCIA\n')
            fprintf('====================================================\n\n\n');
            printpf_caso2(resultados);
            sobrecar = sobrecarga_2(resultados,sistema2);
            imprime_sobrecarga(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
            
            [corte,t,s] = corte_minimo(sistema2);
            clc
            imprime_corte(corte);
            fprintf('\nPressione enter para continuar...\n');
            pause
            sobrecar = sobrecarga_2(resultados,sistema2);
            gargalos = verifica_gargalos(corte,sobrecar,t,s);
            tam_gargalos = size(gargalos);
            if tam_gargalos(1) == 0
                gargalos = linhas_vizinhas_gargalo(sobrecar,sistema1);
            end

            [garg,valor,taxa,taxa_otima,result_otimo,garg_otimo,sistema_otimo] = otimo(sistema1,gargalos,configurar,sistema2);
            clc
            imprime_result(garg,valor,taxa,garg_otimo);
            fprintf('\nPressione enter para continuar...\n');
            pause
            
            resultados = runopf(sistema_otimo,configurar);
            clc
            fprintf('============================================================\n');
            fprintf('   SISTEMA COM ANALISE DE CONTIGENCIA E ALOCACAO DO TCSC\n')
            fprintf('============================================================\n\n\n');
            printpf_caso2(resultados);
            sobrecar = sobrecarga_2(resultados,sistema2);
            imprime_sobrecarga(sobrecar);
            fprintf('\nPressione enter para continuar...\n');
            pause
            
        otherwise
            clc
            fprintf('ERRO: Opcao invalida!!!\n');
            fprintf('Pressione enter para continuar...\n')
            pause
    end
    clc
    fprintf('Informe o cenario desejado: \n');
    fprintf('[1] FPO inicial sem compensacao de reativos, com limites de linhas ignorados\n');
    fprintf('[2] FPO inicial sem compensacao de reativos, considerando limites de fluxo nas linhas\n');
    fprintf('[3] FPO com alocacao de TCSC\n');
    fprintf('[4] Introducao da contingencia mais severa\n');
    fprintf('[5] Introducao da contingencia mais provavel\n');
    fprintf('[0] Voltar\n')
    opcao = input('-> ');
end
end