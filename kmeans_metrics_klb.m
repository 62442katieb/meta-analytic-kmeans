%This script calculates the various metrics for determining the optimal
%parcellation solution for k-means clustering of experiments

%From CBP - Metric 2
%Average Silhouette Value
for a = 1:numel(IDX)
    sil{a} = silhouette(corrmat, IDX{a}, 'correlation');
    avg_sil(a) = mean(sil{a});
    if a > 1
        [h p]= ttest(sil{a}-sil{a-1},0,0.05,'right');
        if h == 1
            avg_sil_sig(a) = p;
        else
            [h p]= ttest(sil{a}-sil{a-1},0,0.01,'left');
            if h == 0
                avg_sil_sig(a) = (-1)*p;
            end
        end
    end
    clear h p
end
clear a

%From CBP - Metric 5
%Variation of Information
for a = 1:numel(IDX)-1
    sol1 = IDX{a};
    for b = 1:max(sol1)
        sol1_clust{b} = find(sol1==b);
        sol1_clust_num(b) = length(find(sol1==b));
    end
    sol2 = IDX{a+1};
    for b = 1:max(sol2)
        sol2_clust{b} = find(sol2==b);
        sol2_clust_num(b) = length(find(sol2==b));
    end
    
    Psol1 = sol1_clust_num./sum(sol1_clust_num);
    Hsol1 = (-1)*sum(Psol1.*log(Psol1));
    Psol2 = sol2_clust_num./sum(sol2_clust_num);
    Hsol2 = (-1)*sum(Psol2.*log(Psol2));
    
    for b = 1:numel(sol1_clust)
        for c = 1:numel(sol2_clust)
            Psol12(b,c) = length(find(ismember(sol1_clust{b}, sol2_clust{c})))/sum(sol1_clust_num);
        end
    end
    
    for b = 1:length(Psol1)
        for c = 1:length(Psol2)
            I(b,c) = Psol12(b,c)*log(Psol12(b,c)/(Psol1(b)*Psol2(c)));
        end
    end
    I(isnan(I)) = 0;
    VI(a) = Hsol1+Hsol2-2*sum(I(:));
    VIvals{a} = I(:);
    if a > 1
        if a < numel(IDX)
            [h p]= ttest2(VIvals{a},VIvals{a-1},0.05,'right');
            if h==1
                VI_ppos(a) = p;
            end
        end
        if a > 1
            [h p] = ttest2(VIvals{a-1},VIvals{a},0.05,'left');
            if h==1
               VI_pneg(a) = (-1)*p;
            end
        end
    end
    
    clear b c sol1 sol2 sol1_clust sol1_clust_num sol2_clust sol2_clust_num Psol1 Psol2 Hsol1 Hsol2 Psol12 I
end
clear a

%From CBP - Metric 6
%Hierarchy Index
for a = 1:numel(IDX)-1
    sol1 = IDX{a};
    for b = 1:max(sol1)
        sol1_clust{b} = find(sol1==b);
    end
    sol2 = IDX{a+1};
    for b = 1:max(sol2)
        sol2_clust{b} = find(sol2==b);
    end

    for b = 1:numel(sol1_clust)
        for c = 1:numel(sol2_clust)
            x(b,c) = length(find(ismember(sol1_clust{b}, sol2_clust{c})))/length(sol1);
        end
    end
    
    xbar = sum(x);
    
    HI(a) = 100*(1-(1/numel(sol2_clust))*sum(max(x)./xbar));
    
    clear sol1 sol2 sol1_clust sol2_clust x xbar b c
end
clear a

%From CBP - Metric 8
%Cluster Consistency
for a = 1:numel(IDX)
    if a == 1
        sol1 = IDX{a};
        for b = 1:max(sol1)
            sol1_clust{b} = find(sol1==b);
            sol1_clust_num(b) = length(find(sol1==b));
        end
        
        cluster_consistency(a,2) = min(sol1_clust_num);
        cluster_consistency(a,1) = mean(sol1_clust_num);
        clear sol1_clust_num sol1_clust sol1
    else
        sol1 = IDX{a-1};
        for b = 1:max(sol1)
            sol1_clust{b} = find(sol1==b);
        end
        sol2 = IDX{a};
        for b = 1:max(sol2)
            sol2_clust{b} = find(sol2==b);
        end

        for b = 1:numel(sol1_clust)
            for c = 1:numel(sol2_clust)
                x(b,c) = length(find(ismember(sol1_clust{b}, sol2_clust{c})));
            end
        end
        cluster_consistency(a,2) = min(max(x, [], 2));
        cluster_consistency(a,1) = mean(max(x, [], 2));
    end
    
    clear sol1 sol2 sol1_clust sol2_clust x b c
end
clear a

subplot(2,2,1), plot(2:10, avg_sil), title('Average Silhouette')
subplot(2,2,2), bar(2:10, cluster_consistency), colormap('jet')
subplot(2,2,3), plot(3:10, VI), title('Variation of Information')
subplot(2,2,4), plot(3:10, HI), title('Hierarchy Index'), hold on, plot(3:10, median(HI)*ones(1,length(HI)), '--')
