clear, clc
addpath /home/applications/spm12

studyname = input('Enter title of study: ', 's');

%if exist([studyname '.mat']) == 0

    matfile = spm_select;
    load(matfile, 'Experiments');
    clear matfile

    TEMPLATE = spm_vol(fullfile(pwd,'MaskenEtc','Grey10_roi.nii'));
    prior = find(spm_read_vols(TEMPLATE));

    xleer = zeros(TEMPLATE.dim+[30 30 30]);

    for i=1:numel(Experiments)
        data = xleer;
        for ii = 1:Experiments(i).Peaks
            data(Experiments(i).XYZ(1,ii):Experiments(i).XYZ(1,ii)+30,Experiments(i).XYZ(2,ii):Experiments(i).XYZ(2,ii)+30,Experiments(i).XYZ(3,ii):Experiments(i).XYZ(3,ii)+30) = ...
                    max(data(Experiments(i).XYZ(1,ii):Experiments(i).XYZ(1,ii)+30,Experiments(i).XYZ(2,ii):Experiments(i).XYZ(2,ii)+30,Experiments(i).XYZ(3,ii):Experiments(i).XYZ(3,ii)+30),Experiments(i).Kernel);
        end
        data = data(16:end-15,16:end-15,16:end-15);
        voxval(:,i) = data(prior);
        clear data
    end

    clear xleer

    corrmat = corr(voxval);

    rmpath /home/applications/spm12/external/fieldtrip/external/stats/
    for a = 2:10
        [IDX{a-1},C{a-1},SUMD{a-1},D{a-1}] = kmeans(corrmat,a,'distance','correlation','emptyaction','singleton','start','cluster','replicates',1000, 'options',statset('MaxIter',1023));
    end
    addpath /home/applications/spm12/external/fieldtrip/external/stats/

    kmeans_metrics_klb

    cluster_sol = IDX{input('Enter number of clusters: ') - 1};
    for a = 1:max(cluster_sol)
        cluster_exps{a} = Experiments(find(cluster_sol==a));
    end

    save([studyname '.mat'])

%else

    load([studyname '.mat'])
    for a = 1:max(cluster_sol)
        se_computeALE_parallel(cluster_exps{a}, [studyname '_Cluster_' num2str(a) '_of_' num2str(max(cluster_sol))], '-');
    end
%end
