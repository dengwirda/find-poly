function polydemo
%POLYDEMO run a "point(s)-in-polygon(s)" demo problem.
%
%   See also INPOLY2, MAKETREE, INPOLYGON

%   Darren Engwirda : 2020 --
%   Email           : darren.engwirda@columbia.edu
%   Last updated    : 31/03/2020

%-------- load some test data --- the NE-US county divisions
    data = loadmsh('test-data/nec.msh');
    data = data.point.coord(:,1:2);

%-------- parse NaN-delimited list to node//edge polygon set
   [node,edge] = fromnans(single(data));
 
%-- make some quasi-random test data, as a rand.-dist. about
%-- the polygon means, range, etc.
    vnum = 512;    
    vert = zeros(length(edge)*vnum,2,'single');
    for kk = 1:length(edge)
        aabb(1) = min(node{kk}(:,1));
        aabb(2) = min(node{kk}(:,2));
        aabb(3) = max(node{kk}(:,1));
        aabb(4) = max(node{kk}(:,2));

        xmid = +.5*(aabb(1)+aabb(3));
        ymid = +.5*(aabb(2)+aabb(4));

        xdel = +.5*(aabb(3)-aabb(1));
        ydel = +.5*(aabb(4)-aabb(2));

        vpos = (1:vnum)+(kk-1)*vnum ;

        vert(vpos,1) = ...
            xdel * randn(vnum,1) + xmid;
        vert(vpos,2) = ...
            ydel * randn(vnum,1) + ymid;
    end

%---- the obvious "slow" way, as a linear loop over polygons
    %{    
    tic

    indx = zeros(size(vert,1),1);
    for kk = 1:length(edge)
        stat = inpolygon( ...
            vert(:,1),vert(:,2),node{kk}(:,1),node{kk}(:,2));
        indx(stat) = kk ;
    end

    iptr = zeros(size(vert,1),2);   % put in sparse list fmt
    have = indx > 0 ; 
    indx = indx(have) ;
    iptr(have,1) = 1:sum(have)+0;
    iptr(have,2) = 2:sum(have)+1;
    
    info.time_slowloop = toc;
    %}    

%----------- the "fast" way, via spatial-trees, sorting, etc
    tic

   [iptr,indx,tree] = findpoly(node,edge,vert);

    info.time_findpoly = toc;
    
%------------------- print out various metrics for the tests
    info.num_poly = length(edge);
    info.num_vert = size(vert,1);
    disp(info);
    
%------------------- draw the polygons, points and aabb-tree
    cols = rand(length(edge),3) * .875 ;

    figure('color','w');
    drawtree(tree);
    axis image; box on;
    title('Spatial indexing');

    have = iptr(:,1) > 0;           % TRUE if enclosed point
    indp = indx(iptr(have,1));      % polygon indx per point

    figure('color','w'); hold on;
    for kk = 1:length(edge)
    patch('faces',edge{kk},'vertices',node{kk}, ...
        'edgecolor',cols(kk,:), ...
        'facecolor','none');
    end   
    scatter(vert( have,1), ...
            vert( have,2),4,cols(indp,:)) ;
    scatter(vert(~have,1), ...
            vert(~have,2),2,'k');
    axis image; box on;
    title('Classification of points');

end

function [node,edge] = fromnans(data)

%---------------------------------- parse NaN delimited data
    nvec = find(isnan(data(:,1))) ;

    if (isempty(nvec))                    % no NaN's at all!
    nvec = [nvec ; size(data,1) ] ;
    end

    if (nvec(end)~=size(data,1) )         % append last poly
    nvec = [nvec ; size(data,1) ] ;
    end

    join = false ; %%!!

    node = cell(length(nvec),1) ;
    edge = cell(length(nvec),1) ;

    next = +1; nout = +1; eout = +1 ;

    for npos = +1 : length(nvec)
        stop = nvec(npos) ;

        pnew = data(next:stop-1,1:2);

        if (~isempty(pnew))
%---------------------------------- push polygon onto output
        nnew = size(pnew,1);

        if (join)
        enew = [(1:nnew-1)', ...
                (2:nnew-0)'; ...
                nnew, +1 ] ;
        else
        enew = [(1:nnew-1)', ...
                (2:nnew-0)'; ...
               ] ;
        end
        
        node {npos} = pnew ;
        edge {npos} = enew ;

        end
        
        next = stop + 1 ;
    end

end



