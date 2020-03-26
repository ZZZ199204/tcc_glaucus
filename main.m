clear all
clc
fprintf('Informe o SEP desejado:\n[1] 6 Barras\n[2] 30 Barras\n[3] 118 Barras\n[0] Sair\n');
opcao = input('-> ');
while opcao ~= 0
    switch opcao
        case 1
            clear all
            cenarios(6);
        case 2
            clear all
            cenarios(30)
        case 3
            clear all
            cenarios(118)
        otherwise
            clc
            fprintf('ERRO: Opção inválida!!!\n');
            fprintf('Pressione enter para continuar...\n')
            pause
    end    
    clc
    fprintf('Informe o SEP desejado:\n[1] 6 Barras\n[2] 30 Barras\n[3] 118 Barras\n[0] Sair\n');
    opcao = input('-> ');
end