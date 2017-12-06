function ClusterExps = BMA_ExportClusterExps_MNI(exps, IDX, clustnum)

tempclust = IDX{clustnum-1};
    for a = 1:clustnum
        ClusterExps{a} = exps(find(tempclust==a));
    end
    
    for a = 1:clustnum
        templateline = '//Reference=MNI';
        thefilname = ['Cluster_' num2str(a) '_of_' num2str(clustnum) '.txt'];
        fid = fopen(thefilname, 'w');
        fprintf(fid, '%s\n', templateline);
        fclose(fid);
        secondstarters = ClusterExps{a};
        
        for b = 1:numel(secondstarters)
            fid = fopen(thefilname, 'a');
            subnum = secondstarters(b).Subject_Total;
            subnum = num2str(subnum);
            fprintf(fid, '%s\n', strcat('//Subjects=',subnum));
            clear subnum
            peaknum = size(secondstarters(b).XYZmm_MNI,1);
            for c = 1:peaknum
                checkpts = secondstarters(b).XYZmm_MNI(c,:);
                fprintf(fid, '%f\t%f\t%f\n', [checkpts(1) checkpts(2) checkpts(3)]);
                clear checkpts
            end
            clear peaknum
            fprintf(fid, '%s\n', '');
            fclose(fid);
        end
        
        clear secondstarters fid thefilname templateline 
    end
