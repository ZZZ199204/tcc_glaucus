function [valor_otimo, sistema_otimo, result_otimo, k_otimo] = otimo_2(sistema,gargalo,configuracao)
    valor_otimo = Inf;
    tam_sistema = size(sistema.branch);
    result_otimo = [];
    sistema_otimo = sistema;
    k_otimo = 0;
    %varia o X de 0.7 a 1
    for k = 0.25:0.01:1
        sistema_novo = sistema;
        for l = 1:tam_sistema(1)
            if sistema_novo.branch(l,1) == gargalo(1) && sistema_novo.branch(l,2) == gargalo(2)
                %recalculando o X e o B na linha de gargalo
                sistema_novo.branch(l,4) = sistema_novo.branch(l,4)*k;
                sistema_novo.branch(l,5) = sistema_novo.branch(l,4)/(sistema_novo.branch(l,4)^2 + sistema_novo.branch(l,3)^2)/sistema_novo.baseMVA;
            end
        end
        %Recalcula o Fluxo de Potencia
        result = runopf(sistema_novo,configuracao);
        if result.f < valor_otimo
            valor_otimo = result.f;
            sistema_otimo = sistema_novo;
            result_otimo = result;
            k_otimo = k;
        end
    end
end