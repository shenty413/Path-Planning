%%%%
clear all;
close all;
% This program uses Dijkstra algorithm to find the shortest path on a 3D
% meshgrid for random start and end point.
% 
% change the step of callMeshData to use different data

% [x,y] = meshgrid(1:0.5:15,1:0.5:15);
%     tri = delaunay(x,y);
% %     z = ones(15,15);
%     z = peaks(29);
% %     trimesh(tri,x,y,z) % plot the mesh data
% numV = 29*29;
%     v = [reshape(x,29*29,1) reshape(y,29*29,1) reshape(z,29*29,1)];
%     f = tri;
% 
[v,f]=obj__read("meshdata.obj");%read .obj files
v=v';
f=f';
%% Get the mesh data
% [vdata,fdata,numV] = getDataFromFile('triceratops.dat',true);

% get the mesh data, input the step of mesh
vdata =v;
fdata=f;
numV = size(v,1);
%% find a certain vertice in all faces

% vInFaceIdx = -1*ones(numV);
% nIdxInFace = zeros(numV,1);
% for i = 1:size(fdata,1)
%     for j = 1:3
%         vInFaceIdx(fdata(i,j),nIdxInFace(fdata(i,j))+1) = i;
%         nIdxInFace(fdata(i,j)) = nIdxInFace(fdata(i,j))+1;
%     end
% end

vInFaceIdx = cell(numV,1);
nIdxInFace = zeros(numV,1);
for i = 1:size(fdata,1)
    for j = 1:size(fdata(i,:),2)
%         vIdx = vInFaceIdx{fdata(i,j)};
        vInFaceIdx{fdata(i,j)}(nIdxInFace(fdata(i,j))+1) = i;
        nIdxInFace(fdata(i,j)) = nIdxInFace(fdata(i,j))+1;
%         vInFaceIdx(fdata(i,j),nIdxInFace(fdata(i,j))+1) = i;
%         nIdxInFace(fdata(i,j)) = nIdxInFace(fdata(i,j))+1;
    end
end

%% plot
figure();
for i = 1:size(fdata,1)
    drawTriangle(vdata(fdata(i,1),:),vdata(fdata(i,2),:),vdata(fdata(i,3),:));
end

%% initialize start and end point
vStart = 530; % 15
vEnd = 428;  % 117 100 33  % error: 123 200

% vStart = floor(mod(rand*1000000,numV))
% vEnd = floor(mod(rand*1000000,numV))

% plot start point and end point
plot3(vdata(vStart,1),vdata(vStart,2),vdata(vStart,3),'b.','Markersize',30)
plot3(vdata(vEnd,1),vdata(vEnd,2),vdata(vEnd,3),'r.','Markersize',30)

% pause for plotting the route
pause;
nState = zeros(numV,1);
distToStart = zeros(numV,1);
vLast = vStart;
nState(vLast) = 1;

% assign the route for every vertice
route = cell(numV,1);
for i=1:numV
    route{i}=i; 
end

vAroundvLast=0;
while true
    % find the vertice around the last chosen vertice
    vAroundvLast = findPointsAround(vLast,vInFaceIdx,fdata,nState,vAroundvLast);
    
    dist = zeros(size(vAroundvLast));
    for i = 1:size(vAroundvLast,2)
        % update the distance to the start point for each around vertice
        [dist(i),distToStart,route] = updateDistToStart(vAroundvLast(i),vLast,vdata,distToStart,route);
    end
    
    % find the minimum distance to the start point
    idx = FindMinDistToStart(nState,distToStart);
    nState(idx) = 1;
    vLast = idx;
    
    % if the end point is reached
    if vLast==vEnd
        break;
    end
end

% plot the route
finalRoute = route{vLast};
plot3(vdata(finalRoute,1),vdata(finalRoute,2),vdata(finalRoute,3),'r-');

routeLength = 0;
for i = 1:size(finalRoute,2)-1
    ddd = pdist([vdata(finalRoute(i),1),vdata(finalRoute(i),2),vdata(finalRoute(i),3);...
        vdata(finalRoute(i+1),1),vdata(finalRoute(i+1),2),vdata(finalRoute(i+1),3)]);
    routeLength = routeLength+ddd;
end
disp('Dijkstra algorithm:')
routeLength
