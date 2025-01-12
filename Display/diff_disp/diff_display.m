function [ ] = diff_display( chk_print, line_search_Result, line_search_Result_std, chkXY, Detector, search_Deg, sample_para)
%Display difference duing wobbler test
%Weizong Xu, April, 2015

A_line=line_search_Result.A_line;
B_line=line_search_Result.B_line;
A_Abso=line_search_Result.A_Abso;
B_Abso=line_search_Result.B_Abso;
Absrp_line=line_search_Result.Absrp_line;

A_line_std=line_search_Result_std.A_line;
B_line_std=line_search_Result_std.B_line;
A_Abso_std=line_search_Result_std.A_Abso;
B_Abso_std=line_search_Result_std.B_Abso;
Absrp_line_std=line_search_Result_std.Absrp_line;

A_lineall_counts(:,1)=A_line(:,1,1);
A_lineall_counts(:,2)=A_line(:,2,1);
B_lineall_counts(:,1)=B_line(:,1,1);
B_lineall_counts(:,2)=B_line(:,2,1);
tot_Det_num=Detector.tot_Det_num;

for i=1+1:tot_Det_num
    A_lineall_counts(:,2)= A_lineall_counts(:,2)+A_line(:,2,i);
    B_lineall_counts(:,2)= B_lineall_counts(:,2)+B_line(:,2,i);
end
Absrp_lineall(:,1)=A_lineall_counts(:,1);
Absrp_lineall(:,2)=A_lineall_counts(:,2)./B_lineall_counts(:,2);


A_lineall_counts_std(:,1)=A_line_std(:,1,1);
A_lineall_counts_std(:,2)=A_line_std(:,2,1);
B_lineall_counts_std(:,1)=B_line_std(:,1,1);
B_lineall_counts_std(:,2)=B_line_std(:,2,1);
for i=1+1:tot_Det_num
    A_lineall_counts_std(:,2)= A_lineall_counts_std(:,2)+A_line_std(:,2,i);
    B_lineall_counts_std(:,2)= B_lineall_counts_std(:,2)+B_line_std(:,2,i);
end
Absrp_lineall_std(:,1)=A_lineall_counts_std(:,1);
Absrp_lineall_std(:,2)=A_lineall_counts_std(:,2)./B_lineall_counts_std(:,2);


if (abs(chkXY(1)-2)<0.0001)
    xaxis='Tilt Y (deg)';
else
    xaxis='Tilt X (deg)';
end

sym_A = get_element_name(sample_para.EleA_num,sample_para.EleA_shell);
sym_B = get_element_name(sample_para.EleB_num,sample_para.EleB_shell);
Atomic_weight_A = get_element_weight(sample_para.EleA_num);
Atomic_weight_B = get_element_weight(sample_para.EleB_num);

c_select=[0.7,0.7,0;1,0,0;0,0,1;0,0.9,0;1,0,1;0,0.5,0.5;0.5,0.5,0.5;0.3,0.3,0.3;0.3,0,0.3;0.3,0.3,0;0,0.3,0.3]; %color matrix for display


max_A=max(max(A_line(:,2,:)));
max_B=max(max(B_line(:,2,:)));
for i=1:tot_Det_num
    A_line_norm(:,1,i) = A_line(:,1,i);
    A_line_norm(:,2,i) = A_line(:,2,i)/max_A;

    B_line_norm(:,1,i) = B_line(:,1,i);
    B_line_norm(:,2,i) = B_line(:,2,i)/max_B;
end

max_A_std=max(max(A_line_std(:,2,:)));
max_B_std=max(max(B_line_std(:,2,:)));
for i=1:tot_Det_num
    A_line_norm_std(:,1,i) = A_line_std(:,1,i);
    A_line_norm_std(:,2,i) = A_line_std(:,2,i)/max_A_std;

    B_line_norm_std(:,1,i) = B_line_std(:,1,i);
    B_line_norm_std(:,2,i) = B_line_std(:,2,i)/max_B_std;
end


%factor ~=1/3.7;%dependes on ion crossection, detector efficiency, probe current...
k_AB_ideal = sample_para.k_AB_ideal; % ideal k ratio in for composition in wt%
atomic_ratio_AB = sample_para.Atomic_ratio;
k_AB_ideal_atomic = k_AB_ideal/Atomic_weight_A*Atomic_weight_B;
Int_ratio_factor= atomic_ratio_AB/k_AB_ideal_atomic;
Absrp_line_k = Absrp_line; 
for i=1:tot_Det_num
Absrp_line_k(:,2,i) = Absrp_line(:,2,i)*Int_ratio_factor;
end

k_AB_ideal_std = sample_para.k_AB_ideal; % ideal k ratio in for composition in wt%
atomic_ratio_AB_std = sample_para.Atomic_ratio;
k_AB_ideal_atomic_std = k_AB_ideal_std/Atomic_weight_A*Atomic_weight_B;
Int_ratio_factor_std= atomic_ratio_AB_std/k_AB_ideal_atomic_std;
Absrp_line_k_std = Absrp_line; 
for i=1:tot_Det_num
Absrp_line_k_std(:,2,i) = Absrp_line_std(:,2,i)*Int_ratio_factor_std;
end



%Display results


figure;
subplot(2,3,1)

hold on;
for i=1:tot_Det_num
    Plot2Dim(A_Abso_std(:,:,i), ['Absorption percentage ', sym_A], 'p', xaxis, 'a.u.');
    axis([-search_Deg search_Deg 0 1])
end
for i=1:tot_Det_num
    scatter(A_Abso(:,1,i),A_Abso(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(A_Abso(:,:,i), ['Absorption percentage ', sym_A], 'r', xaxis, 'a.u.');
end
hold off;

subplot(2,3,2)
%figure;
hold on;
for i=1:tot_Det_num
    Plot2Dim(B_Abso_std(:,:,i), ['Absorption percentage ', sym_B], 'p', xaxis, 'a.u.');
    axis([-search_Deg search_Deg 0 1])
end
for i=1:tot_Det_num
    scatter(B_Abso(:,1,i),B_Abso(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(B_Abso(:,:,i), ['Absorption percentage ', sym_B], 'r', xaxis, 'a.u.');
end
hold off;

subplot(2,3,3)
%figure;
hold on;
for i=1:tot_Det_num
    Plot2Dim(A_line_std(:,:,i), [sym_A, ' total counts'], 'p', xaxis, 'a.u.');
end
scatter(A_lineall_counts_std(:,1),A_lineall_counts_std(:,2),'filled',...
              'MarkerEdgeColor',[0 0.5 1],...
              'MarkerFaceColor',[0 0.5 1]);
for i=1:tot_Det_num
        scatter(A_line(:,1,i),A_line(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(A_line(:,:,i), [sym_A, ' total counts'], 'p', xaxis, 'a.u.');
end
scatter(A_lineall_counts(:,1),A_lineall_counts(:,2),30,'filled',...
              'MarkerEdgeColor',[1 0 1],...
              'MarkerFaceColor',[1 0 1]);
          
hold off;

subplot(2,3,4)
%figure;
hold on;
for i=1:tot_Det_num
    Plot2Dim(B_line_std(:,:,i), [sym_B, ' total counts'], 'p', xaxis, 'a.u.');
end
scatter(B_lineall_counts_std(:,1),B_lineall_counts_std(:,2),'filled',...
              'MarkerEdgeColor',[0 0.5 1],...
              'MarkerFaceColor',[0 0.5 1]);
for i=1:tot_Det_num
        scatter(B_line(:,1,i),B_line(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(A_line(:,:,i), [sym_A, ' total counts'], 'p', xaxis, 'a.u.');
end
scatter(B_lineall_counts(:,1),B_lineall_counts(:,2),30,'filled',...
              'MarkerEdgeColor',[1 0 1],...
              'MarkerFaceColor',[1 0 1]);
hold off;



    subplot(2,3,5)
    %figure;
    hold on;
    for i=1:tot_Det_num
        Plot2Dim(A_line_norm_std(:,:,i), [sym_A, ' normalized counts'], 'p', xaxis, 'a.u.');
    end
    
    for i=1:tot_Det_num
        scatter(A_line_norm(:,1,i),A_line_norm(:,2,i),'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:));
    end
    axis([-search_Deg search_Deg 0 1.1])
    hold off;

    subplot(2,3,6)
    %figure;
    hold on;
    for i=1:tot_Det_num
       Plot2Dim(B_line_norm_std(:,:,i), [sym_B, ' normalized counts'], 'p', xaxis, 'a.u.');
    end
    
    for i=1:tot_Det_num
               scatter(B_line_norm(:,1,i),B_line_norm(:,2,i),'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:));

    end
    axis([-search_Deg search_Deg 0 1.1])
    hold off;

    
    figure;
    subplot(2,2,1)
    hold on;
    for i=1:tot_Det_num
        Plot2Dim(Absrp_line_std(:,:,i), 'Correction coefficient due to absorption/shadowing', 'p', xaxis, 'a.u.');
    end
    scatter(Absrp_lineall_std(:,1),Absrp_lineall_std(:,2),'filled',...
              'MarkerEdgeColor',[0 0 1],...
              'MarkerFaceColor',[0 0.5 1]);
    
    for i=1:tot_Det_num
        scatter(Absrp_line(:,1,i),Absrp_line(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(A_line(:,:,i), [sym_A, ' total counts'], 'p', xaxis, 'a.u.');
    end
    scatter(Absrp_lineall(:,1),Absrp_lineall(:,2),30,'filled',...
              'MarkerEdgeColor',[1 0 1],...
              'MarkerFaceColor',[1 0 1]);
    hold off;



%    figure;
    subplot(2,2,2)
    hold on;
    for i=1:tot_Det_num
        Plot2Dim(Absrp_line_k_std(:,:,i), ['Calculated counts ratio of ' sym_A, '/', sym_B], 'p', xaxis, 'a.u.');
    end
    scatter(Absrp_lineall_std(:,1),Absrp_lineall_std(:,2)*Int_ratio_factor_std,'filled',...
              'MarkerEdgeColor',[0 0 1],...
              'MarkerFaceColor',[0 0.5 1]);
          
    for i=1:tot_Det_num
        scatter(Absrp_line_k(:,1,i),Absrp_line_k(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(A_line(:,:,i), [sym_A, ' total counts'], 'p', xaxis, 'a.u.');
    end
    scatter(Absrp_lineall(:,1),Absrp_lineall(:,2)*Int_ratio_factor,30,'filled',...
              'MarkerEdgeColor',[1 0 1],...
              'MarkerFaceColor',[1 0 1]);
    hold off;
    
    
    subplot(2,2,3)
    hold on;
    for i=1:tot_Det_num
        scatter(Absrp_line_k(:,1,i),(Absrp_line_k(:,2,i)-Absrp_line_k_std(:,2,i))./Absrp_line_k_std(:,2,i),30, 'filled',...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',c_select(i,:))
    %Plot2Dim(A_line(:,:,i), [sym_A, ' total counts'], 'p', xaxis, 'a.u.');
    end
    scatter(Absrp_lineall(:,1),(Absrp_lineall(:,2)-Absrp_lineall_std(:,2))./Absrp_lineall_std(:,2),30,'filled',...
              'MarkerEdgeColor',[1 0 1],...
              'MarkerFaceColor',[1 0 1]);
    grid on;
    hold off;

%********************************
%set(gca,'DefaultTextFontSize',38)
c1_select=[241,196,90;190,29,44;0,144,189;137,198,55;126,47,142;162,20,47;77,190,238;0,0,0]/255;
%c1_select=[237,177,32;217,83,25;0,144,189;119,172,48;126,47,142;162,20,47;77,190,238;0,0,0]/255;
%c2_select=[245,211,131;237,139,97;81,211,255;169,214,109;198,130,213;235,90,119;139,213,243;0,0,0]/255;
%c2_select=[245,211,131;190,29,44;81,211,255;169,214,109;198,130,213;235,90,119;139,213,243;0,0,0]/255;
%c22_select=[0.7,0.7,0.35;1,0.5,0.5;0.5,0.5,1;0.45,0.9,0.45;1,0.5,1;0.25,0.5,0.5;0.25,0.25,0.25;0.15,0.15,0.15;0.3,0.15,0.3;0.3,0.3,0.15;0.15,0.3,0.3];
    %;155,30,45
c_select = [c1_select;c_select];
%c2_select = [c2_select;c22_select];
%c2_select = c_select;
%kk=1;
%sym_shape=['o';'o';'o';'o';'o';'o';'o';'o';'o'];
%sym_shape=['s';'o';'^';'v';'d';'+';'*';'<';'>'];
if (chk_print>0)
figure;
set(gca,'FontSize',18)
hold on;
plot(-30:1:30,ones(61)*0.1,'color',[0.75,0.75,0.75],'LineWidth',2);
plot(-30:1:30,-ones(61)*0.1,'color',[0.75,0.75,0.75],'LineWidth',2);
plot(-30:1:30,-ones(61)*0.0,'--','color',[0.75,0.75,0.75],'LineWidth',2);

for i=1:tot_Det_num
    %scatter(Absrp_line_k(:,1,i),(Absrp_line_k(:,2,i)-Absrp_line_k_std(:,2,i))./Absrp_line_k_std(:,2,i),30, 'filled',...

    plot(Absrp_line_k(:,1,i),(Absrp_line_k(:,2,i)-Absrp_line_k_std(:,2,i))./Absrp_line_k_std(:,2,i),'color',c_select(i,:),'LineWidth',3);

    title('Ratio difference between actual and zero incline angle')
end 
%scatter(Absrp_lineall(:,1),(Absrp_lineall(:,2)-Absrp_lineall_std(:,2))./Absrp_lineall_std(:,2),30,'filled',...

plot(Absrp_lineall(:,1),(Absrp_lineall(:,2)-Absrp_lineall_std(:,2))./Absrp_lineall_std(:,2),'color',c_select(5,:),'LineWidth',5);

axis([-30 30 -0.5 0.5]);
set(gca,'YTick',-0.5:0.1:0.5)
xlabel(xaxis)
ylabel('Deviation (a.u.)')        
box on;
hold off;
if (chk_print==1)
print('wobb_Fig_out_ratio_error','-depsc','-tiff')
print('wobb_Fig_out_ratio_error','-dpng','-r300')
end

end



%Calculate composition ( like in composition_cal.m set *.std as simulated results, *.changes as exp results)
comp_ratio_out = zeros(length(Absrp_lineall), tot_Det_num+2);
k_AB_ideal = sample_para.k_AB_ideal;
comp_ratio_out(:,1)=Absrp_lineall(:,1); %Tilt Angle

    for i=1:length(Absrp_lineall)
    
        if (chkXY == 2) % 2) along Y tilt
            TiltY=Absrp_lineall(i,1);
            TiltX=sample_para.TiltX;
        else
            TiltX=Absrp_lineall(i,1); % other value, along X tilt
            TiltY=sample_para.TiltY;
        end
        
        %[point_out] = single_spot(TiltX, TiltY, tot_Det_num, sample_para_std, holder_para_std, angle_search_std, SpuriousX);
        %correction_factor = k_AB_ideal./point_out(:,4);

        for j=1:tot_Det_num
            correction_factor = k_AB_ideal./Absrp_line_std(i,2,j);
            comp_ratio_out (i,j+1)=Absrp_line(i,2,j)*Int_ratio_factor*correction_factor;
            %comp_ratio_out (i,j+1)=Absrp_line(i,2,j)*Int_ratio_factor*correction_factor(j);
        end
        correction_factor = k_AB_ideal/Absrp_lineall_std(i,2);
        comp_ratio_out (i,tot_Det_num+2)=Absrp_lineall(i,2)*Int_ratio_factor*correction_factor;
        %comp_ratio_out (i,tot_Det_num+2)=Absrp_lineall(i,2)*Int_ratio_factor*correction_factor(tot_Det_num+1);
    end
    
   composition_diff_display( chk_print, comp_ratio_out, sample_para, chkXY ); 
    

    
%    subplot(2,2,3)
%    %figure;
%    hold on;
%    for i=1:tot_Det_num_in
%        plot(ratio_exp(:,1,i),ratio_exp(:,2,i),'-o','color',c_select(i,:),'LineWidth',2,'MarkerSize',8);
%        title(['Experimenal counts ratio of ', sym_A, '/', sym_B])
%    end
%    plot(ratio_exp_all(:,1),ratio_exp_all(:,2),'-o','color',[1,0,1],'LineWidth',2,'MarkerSize',8);
%    axis([-search_Deg search_Deg 0.15 0.35]);
%    xlabel(xaxis)
%    ylabel('a.u.')        
%    grid on;
%    hold off;

%    subplot(2,2,4)
%    %figure;
%    hold on;
%    for i=1:tot_Det_num
%       Plot2Dim(Absrp_line(:,:,i), 'Comparison between Exp and Cal counts ratio', 'p', xaxis, 'a.u.');
%    end
    
%    for i=1:tot_Det_num_in
%       plot(ratio_exp(:,1,i),ratio_exp(:,2,i),'-o','color',c_select(i,:),'LineWidth',2,'MarkerSize',8);
%    end
%    scatter(Absrp_lineall(:,1),Absrp_lineall(:,2)*Int_ratio_factor+correct_test,'filled',...
%              'MarkerEdgeColor',[0 0 1],...
%              'MarkerFaceColor',[0 0.5 1]);
%    plot(ratio_exp_all(:,1),ratio_exp_all(:,2),'-o','color',[1,0,1],'LineWidth',2,'MarkerSize',8);
%    axis([-search_Deg search_Deg 0.15 0.35])
%    hold off;



if (chk_print>0)
    
    %Absrp_lineall_std1=Absrp_lineall_std;
    %Absrp_lineall_std1(:,2)=Absrp_lineall_std(:,2)*Int_ratio_factor_std;
    %Absrp_lineall1=Absrp_lineall;
    %Absrp_lineall1(:,2)=Absrp_lineall1(:,2)*Int_ratio_factor;
    figure;
    set(gca,'FontSize',18)
    hold on;
    for i=1:tot_Det_num
        %Plot2Dim(Absrp_line_k_std(:,:,i), ['Calculated counts ratio of ' sym_A, '/', sym_B], 'p', xaxis, 'a.u.');
        %Plot2Dim_factor(Absrp_line_k_std(:,:,i), ['Calculated counts ratio of ' sym_A, '/', sym_B], 3, xaxis, 'Al-K/Ni-K ratio (a.u.)',c_select(i,:),1);
        plot(Absrp_line_k_std(:,1,i),Absrp_line_k_std(:,2,i),'--','LineWidth',3, 'color',c_select(i,:));
    end
    %Plot2Dim_factor(Absrp_lineall_std1, ['Calculated counts ratio of ' sym_A, '/', sym_B], 5, xaxis, 'a.u.',c2_select(5,:),1);
    plot(Absrp_lineall_std(:,1),Absrp_lineall_std(:,2)*Int_ratio_factor_std,'--','LineWidth',5, 'color',c_select(5,:));
    %scatter(Absrp_lineall_std(:,1),Absrp_lineall_std(:,2)*Int_ratio_factor_std,'filled',...
    %          'MarkerEdgeColor',[0 0 1],...
    %          'MarkerFaceColor',[0 0.5 1]);
          
    for i=1:tot_Det_num
        Plot2Dim_factor(Absrp_line_k(:,:,i), ['Calculated counts ratio of ' sym_A, '/', sym_B], 3, xaxis, 'a.u.',c_select(i,:),1);
        %plot(Absrp_line_k(:,1,i),Absrp_line_k(:,2,i),'--','LineWidth',3, 'color',c_select(i,:));
        %scatter(Absrp_line_k(:,1,i),Absrp_line_k(:,2,i),30, 'filled',...
        %      'MarkerEdgeColor',[0 .5 .5],...
        %      'MarkerFaceColor',c_select(i,:))

    end
    %Plot2Dim_factor(Absrp_lineall1, ['Calculated counts ratio of ' sym_A, '/', sym_B], 5, xaxis, 'a.u.',c2_select(5,:),1);
    plot(Absrp_lineall(:,1),Absrp_lineall(:,2)*Int_ratio_factor,'LineWidth',5, 'color',c_select(5,:));

    %scatter(Absrp_lineall(:,1),Absrp_lineall(:,2)*Int_ratio_factor,30,'filled',...
    %          'MarkerEdgeColor',[1 0 1],...
    %          'MarkerFaceColor',[1 0 1]);

    hold off;
    box on;
    %axis([-30 30 -0.5 0.5]);
    xlim([-30 30]);
if (chk_print==1)
print('Fig_out_wobb_kratio','-depsc','-tiff');
print('Fig_out_wobb_kratio','-dpng','-r300')
end 
    
    


end




end

