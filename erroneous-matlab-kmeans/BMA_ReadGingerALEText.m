    addpath /home/applications/spm12
    
    %Select the .txt file you want to turn into a variable
    filename = spm_select;
    
    %Creates a column vector of cells, each containing one line of the file
    CStr = dataread('file', filename, '%s', 'delimiter', '\n');
    
    %Determine the reference space for the coordinates
    if strfind(CStr{1}, 'Talairach')
        ref='Tal';
    elseif strfind(CStr{1}, 'MNI')
        ref='MNI';
    else
        disp('No reference space specified!')
        return
    end
    
    %Removes the reference space line since it has already been determined
    CStr(1) = [];
    
    %This program will parcellate experiments using empty lines, this makes
    %sures the last line will be an empty line
    if strcmp(CStr(length(CStr)), '') == 0
        CStr(length(CStr)+1) = {''};
    end
    
    %Find the indices of the blank lines
    findblanks = find(strcmp(CStr, ''));
    
    %The number of blanks should be equal to the number of experiments, so
    %lets cycle through each to parcellate the coordinates, subjects,
    %names, etc
    for a = 1:length(findblanks)
        if a == 1
            temp = CStr(1:(findblanks(a)-1));
        else
            temp = CStr((findblanks(a-1)+1):(findblanks(a)-1));
        end
        coords = [];
        conds = [];
        for b = 1:numel(temp)
            if strfind(temp{b}, '//')
                if strfind(temp{b}, 'Subjects=')
                    newtemp = temp{b};
                    subnum = str2num(newtemp(find(newtemp=='=')+1:length(newtemp)));
                    clear newtemp
                else
                    newtemp = temp{b};
                    conds = [conds newtemp(find(newtemp=='/', 1, 'last')+1:length(newtemp))];
                    clear newtemp
                end
            else
                coords = [coords; str2num(temp{b})];
            end
        end
        Experiments(a).Name = conds;
        Experiments(a).Subject_Total = subnum;
        clear temp subnum
        if ref=='Tal'
            Experiments(a).XYZmm_Tal = coords;
            coords = coords';
            
            icbm_spm = [0.9254 0.0024 -0.0118 -1.0207
	   	   -0.0048 0.9316 -0.0871 -1.7667
            0.0152 0.0883  0.8924  4.0926
            0.0000 0.0000  0.0000  1.0000];

            % invert the transformation matrix
            icbm_spm = inv(icbm_spm);

            % apply the transformation matrix
            inpoints = [coords; ones(1, size(coords, 2))];
            inpoints = icbm_spm * inpoints;

            % format the outpoints, transpose if necessary
            outpoints = inpoints(1:3, :);
            
            Experiments(a).XYZmm_MNI = outpoints';
            
            clear outpoints coords inpoints icbm_spm
            
        elseif ref=='MNI'
            Experiments(a).XYZmm_MNI = coords;
            coords = coords';
            
            icbm_spm = [0.9254 0.0024 -0.0118 -1.0207
	   	   -0.0048 0.9316 -0.0871 -1.7667
            0.0152 0.0883  0.8924  4.0926
            0.0000 0.0000  0.0000  1.0000];

            % apply the transformation matrix
            inpoints = [coords; ones(1, size(coords, 2))];
            inpoints = icbm_spm * inpoints;

            % format the outpoints, transpose if necessary
            outpoints = inpoints(1:3, :);
            
            Experiments(a).XYZmm_Tal = outpoints';
            
            clear outpoints coords inpoints icbm_spm
        end
        clear conds
    end
    
    clear a b findblanks filename ref CStr
    
    for a = 1:numel(Experiments)
        coords = Experiments(a).XYZmm_MNI;
        
        thexs = (coords(:,1)+75)/2;%for 2x2x2 76 and divide by 2
        theys = (coords(:,2)+111)/2;%for 2x2x2 112 and divide by 2
        thezs = (coords(:,3)+68)/2;%for 2x2x2 70 and divide by 2
     
     for b = 1:length(thexs) 
          top = ceil(thexs(b));
          bottom = floor(thexs(b));
          middle = (top-bottom)/2 + bottom;
          diff = middle - thexs(b);
          if diff > 0
              thexs(b) = floor(thexs(b));
          else
              thexs(b) = ceil(thexs(b));
          end
     end
     
     for c = 1:length(theys)
          top2 = ceil(theys(c));
          bottom2 = floor(theys(c));
          middle2 = (top2-bottom2)/2 + bottom2;
          diff2 = middle2 - theys(c);
          if diff2 > 0
              theys(c) = floor(theys(c));
          else
              theys(c) = ceil(theys(c));
          end
     end
     
     for d = 1:length(thezs)
          top3 = ceil(thezs(d));
          bottom3 = floor(thezs(d));
          middle3 = (top3-bottom3)/2 + bottom3;
          diff3 = middle3 - thezs(d);
          if diff3 > 0
              thezs(d) = floor(thezs(d));
          else
              thezs(d) = ceil(thezs(d));
          end
     end
     
     XYZmm(:,1) = thexs;
     XYZmm(:,2) = theys;
     XYZmm(:,3) = thezs;
     
    Experiments(a).XYZ_MNI = XYZmm;
    
    clear coords XYZmm thexs theys thezs top3 bottom3 middle3 diff3 top2 bottom2 middle2 diff2 top bottom middle diff
    
    coords = Experiments(a).XYZmm_Tal;
    
     thexs = (coords(:,1)+80)/2;%for 2x2x2 76 and divide by 2
     theys = (coords(:,2)+116)/2;%for 2x2x2 112 and divide by 2
     thezs = (coords(:,3)+62)/2;%for 2x2x2 70 and divide by 2
     
     for b = 1:length(thexs) 
          top = ceil(thexs(b));
          bottom = floor(thexs(b));
          middle = (top-bottom)/2 + bottom;
          diff = middle - thexs(b);
          if diff > 0
              thexs(b) = floor(thexs(b));
          else
              thexs(b) = ceil(thexs(b));
          end
     end
     
     for c = 1:length(theys)
          top2 = ceil(theys(c));
          bottom2 = floor(theys(c));
          middle2 = (top2-bottom2)/2 + bottom2;
          diff2 = middle2 - theys(c);
          if diff2 > 0
              theys(c) = floor(theys(c));
          else
              theys(c) = ceil(theys(c));
          end
     end
     
     for d = 1:length(thezs)
          top3 = ceil(thezs(d));
          bottom3 = floor(thezs(d));
          middle3 = (top3-bottom3)/2 + bottom3;
          diff3 = middle3 - thezs(d);
          if diff3 > 0
              thezs(d) = floor(thezs(d));
          else
              thezs(d) = ceil(thezs(d));
          end
     end
     
     XYZmm(:,1) = thexs;
     XYZmm(:,2) = theys;
     XYZmm(:,3) = thezs;
     
    Experiments(a).XYZ_Tal = XYZmm;
    
    clear coords XYZmm thexs theys thezs top3 bottom3 middle3 diff3 top2 bottom2 middle2 diff2 top bottom middle diff
    
    end
    
    clear a b c d