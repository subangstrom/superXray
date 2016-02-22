function [ comp_ratio_out, comp_ratio_atomic ] = composition_cal_single_spot( exp_A, exp_B, tot_Det_num, sample_para, holder_para, holder_frame_para, angle_search, SpuriousX)
%Calculate composition of AxBy based on k_ideal and correction coefficient
%Single spot, only for detector sum signal
%Beta version, error estimation is not available. Further code modifications will be done.
%Weizong Xu, April, 2015

%[ A_exp, A_exp_norm, max_A_exp, B_exp, B_exp_norm, max_B_exp, ratio_exp, ratio_exp_all, tot_Det_num] = read_exp_data( exp_file );

if (tot_Det_num ==0)
    comp_ratio_out = 0;
    comp_ratio_atomic = 0;
    return;
end

cal_chk=sample_para(12); 
%comp_ratio_out = zeros(length(ratio_exp_all), tot_Det_num+2);


if (cal_chk ~= 1)
    comp_ratio_out=0;
    comp_ratio_atomic = 0;
    uiwait(msgbox('Known composition! Calculation is not necessary.'));
    disp('Known composition! Calculation is not necessary.');

    return;
else
    %Calculate composition without knowing/comparing the ideal one.
    comp_ratio_ini=exp_A/exp_B; %Sum signal only
    ratio_exp=exp_A/exp_B;
    
    EleA_num = sample_para(13);
    EleA_shell = sample_para(14);
    EleB_num = sample_para(15);
    EleB_shell = sample_para(16);
    AB_Density =  sample_para(18);
    k_factor_others = sample_para(19);
    k_AB_ideal = sample_para(20);
    cal_chk2 = 0;
    Absorp_table (:,:,1) = xlsread ('Absorption coefficient_K.xlsx'); %K-shell cm2/g
    Absorp_table (:,:,2) = xlsread ('Absorption coefficient_L.xlsx'); %L-shell cm2/g
    Absorp_table (:,:,3) = xlsread ('Absorption coefficient_M.xlsx'); %M-shell cm2/g
    
    Atomic_weight_A = get_element_weight(EleA_num);
    Atomic_weight_B = get_element_weight(EleB_num);
    k_AB_ideal_atomic = k_AB_ideal/Atomic_weight_A*Atomic_weight_B;
    %use ideal ratio witout absorption to calculate the rough composition
    %for i=1:length(ratio_exp_all)
    %    for j=1:tot_Det_num
            comp_ratio_ini=k_AB_ideal_atomic * ratio_exp;
    %    end
    %    comp_ratio_ini (i,tot_Det_num+2)=k_AB_ideal_atomic * ratio_exp_all(i,2);
    %end
    
    %use above calculated rough composition to calculate uA and uB
    %iterately approach to the real composition
%    for i=1:length(ratio_exp_all)
%        Iteration_for_data_point = i
%        if (chkX_Y == 2) % 2) along Y tilt
%            TiltY=comp_ratio_ini(i,1);
            TiltX=sample_para(3);
%        else
%            TiltX=comp_ratio_ini(i,1); % other value, along X tilt
            TiltY=sample_para(4);
%        end
        
%        for j=1:tot_Det_num+1
            %Iteration begin here
            for k=1:100
                Atomic_ratio = comp_ratio_ini;
                %[uA, uB, temp] = read_element( EleA_num, EleA_shell, EleB_num, EleB_shell, Atomic_ratio, AB_Density, k_factor_others, cal_chk2);
                
                %Copy lines from read_element.m to avoid slow IO reading.
                %Get composition
                Atomic_percent_A = Atomic_ratio/(1+Atomic_ratio);
                Atomic_percent_B = 1 - Atomic_percent_A;
                Weight_percent_A = Atomic_percent_A*Atomic_weight_A/(Atomic_percent_A*Atomic_weight_A+Atomic_percent_B*Atomic_weight_B);
                Weight_percent_B = 1 - Weight_percent_A;

                %Get absorption coefficient
                uA = Absorp_table(EleA_num,EleA_num,EleA_shell)*Weight_percent_A + Absorp_table(EleB_num,EleA_num,EleA_shell)*Weight_percent_B;
                uA = uA * AB_Density;
                uB = Absorp_table(EleA_num,EleB_num,EleB_shell)*Weight_percent_A + Absorp_table(EleB_num,EleB_num,EleB_shell)*Weight_percent_B;
                uB = uB * AB_Density;
                
                sample_para_temp = sample_para;
                sample_para_temp(7)=uA;
                sample_para_temp(8)=uB;
                sample_para_temp(17)=Atomic_ratio;
                sample_para_temp(12)=0; %set cal_chk=0, enable composition calculation

                [point_out] = single_spot(TiltX, TiltY, tot_Det_num, sample_para_temp, holder_para, holder_frame_para, angle_search, SpuriousX);
                correction_factor = k_AB_ideal_atomic/point_out(tot_Det_num+1,4);
%                if (j<=tot_Det_num)
%                    swap = correction_factor * ratio_exp(i,2,j);
%                else
                    swap = correction_factor * ratio_exp;
%                end
            
                if (abs(comp_ratio_ini -swap)>1e-5)
                    comp_ratio_ini = swap;
                else
                    %Done, convert from atomic ratio to weight ratio
                    comp_ratio_atomic=comp_ratio_ini; %atomic percent output
                    comp_ratio_ini = (comp_ratio_ini *Atomic_weight_A)/((comp_ratio_ini *Atomic_weight_A)+((1-comp_ratio_ini) *Atomic_weight_B)); %weight percent output
                    break;
                end              
            end
%        end
%    end
    comp_ratio_out = comp_ratio_ini;
    comp_ratio_atomic=comp_ratio_atomic/(1+comp_ratio_atomic);

disp('    ')
disp('Composition (Al wt.%) after iteration')
disp(num2str(comp_ratio_out))
disp('Composition (Ni wt.%) after iteration')
disp(num2str(1-comp_ratio_out))

disp('Composition (Al at.%) after iteration')
disp(num2str(comp_ratio_atomic))
disp('Composition (Ni at.%) after iteration')
disp(num2str(1-comp_ratio_atomic))
end




