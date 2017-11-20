% 24681 Team Project
% Team Tricerapiggys
% Code written by Zhuohao Zhang
% All rights reserved by team Tricerapiggys

% The purpose of this program is to implement an advanced ant-colony 
% algorithm on robotic path planning. More specifically, the goal of this 
% program is being able to find the shortest path on a 3d object, given a 
% map data preprocessed from the .obj file of the 3d object. A starting 
% point and a destination point are also given. 

% probablistic rule on route picking: the ant will sense the
% amount of pheromone on every neighouring node. Add them all up and find
% the "weight" of each neighbouring node. Then rng will be used to assign a
% random number on each node, times it with its weight. Whichever node end
% up having the largest number will be the ant's next stop. 

% The basis of ant colony algorithm is described as follows: 
% 1. Each ant is a variable length array which stores the indices of the nodes
%    that it has travelled. 
% 2. At each time step, every ant picks one of its neighbouring nodes as
%    the next stop. The picking process is based on probablistic rule.
% 3. Ants deploy "pheromone" on the paths that it has travelled. The higher
%    amount of pheromone left on a connecting edge, the more likely the
%    following ants are going to choose this edge to travel. 
% 4. To prevent quick convergence, a mechanism called pheromone evaporation
%    will be applied. At each time step, the amount of pheromone left on
%    each edge will decrease exponentially. The equation is: pheromone*(1-k)
% 5. Multiple termination conditions should be applied to each ant in order
%    to prevent infinite looping. 
% 6. After reaching the destination point, each ant "retraces" back the
%    trail and update the pheromone along the trail. This is a rewarding 
%    mechanism based on how short the route is. 

%% Main program

% inputs are: 
% 1. map 
%    preprocessed obj file, first and second columns indicate connecting
%    edges. Third column indicates distances between each pair of nodes.
%    Fourth column records the pheromone left on this edge. 
% 2. numAnts
%    Number of ants deployed to find the shortest route. 
% 3. start 
%    index of the starting node 
% 4. end 
%    index of the destination node 

[v,f]=obj__read("donut.obj");
v=v';
f=f';
scatter3(v(:,3),v(:,2),v(:,1));
edges = [];
for i = 1:size(f,1)
    for j=1:size(f(i,:),2)
        if j==size(f(i,:),2)
            edges = [edges;[f(i,j),f(i,1)]];
        else
            edges = [edges;[f(i,j),f(i,j+1)]];
        end
    end
end
for i = 1:size(f,1)
    j=size(f(i,:),2);
    while(j>=1)
        if j==1
            edges = [edges;[f(i,1),f(i,size(f(i,:),2))]];
        else
            edges = [edges;[f(i,j),f(i,j-1)]];
        end
        j=j-1;
    end
end
uedges = unique(edges,'rows');  
length=[];
for i =1:size(uedges,1)
    length=[length;norm(v(uedges(i,1),:)-v(uedges(i,2),:))];
end
uedges = [uedges,length];
for i =1:size(uedges,1)
    if(uedges(i,1)==uedges(i,2))
        uedges(i,:)=[0,0,0];
    end
end
uedges1 = unique(uedges,'rows');
if(sum(uedges1(1,:)==[0,0,0])==3)
uedges1(1,:)=[];
end

% function route=ant_colony_algorithm(map,numAnts,start,destination)
map = uedges; 
numAnts=5;
start=1;
destination=300;

% initialize parameters 

% generate the ants 
ant=zeros(1,numAnts);
ant(1,:)=start;
route=zeros(1,numAnts);

% pheromone evaporation rate
k = 0.25; % For each time step, 25% of the pheromone evaporates. 

% initial pheromone ditributed on every edge
initial_p=1;
map(:,4)=initial_p;

% rewarding mechanism
p_reward=0.4;

% amount of pheromone distributed on an edge by an ant 
p=0.2;

% a step table that records each ant's currrent step number 
step=ones(1,numAnts);

% Inside the first while loop, the ant colony algorithm starts. Each loop
% represents a time step that all ants take.
while(size(ant,2)~=0)
    
    % Use a for loop to loop through all ants.
    for i=1:size(ant,2)
        % Each ant searches its local routing table and picks its next stop. It should not go back.
        % If the ant reaches a dead corner, it dies without retracing back.
        % Record the next stop in its memory.
        
        % construct a local routing table
        current_node=ant(step(i),i);
        local_routing_index=map(:,1)==current_node;
        local_routing=map(local_routing_index,:);
        
        % go through the local routing table, check available nodes, exclude
        % options such as going back
        for a=1:size(local_routing,1)
            % check every element along column i of ant matrix
            for b=1:size(ant(:,i),1)
                if(local_routing(a,2)==ant(b,i))
                    % if an available node is in the ant's past route, exclude this
                    % node from the local routing table
                    local_routing(a,:)=[];
                end
            end
        end
        
        % check for dead corner, ==========================================
        if isempty(local_routing)
            % if this ant enters a dead corner, it dies without retracing back its
            % route. Release its memory.
            ant(:,i)=[];
        end
        
        % From the updated local routing table, use probablistic rule to
        % find the next node to go
        total_p_temp=sum(map(:,4)); local_routing(:,4)=local_routing(:,4)/total_p_temp;
        for a=1:size(local_routing,1)
            local_routing(a,4)=local_routing(a,4)*rand;
        end
        [~,I]=max(local_routing(:,4));
        next_node=local_routing(I,2);
        
        % add the index of next node to the route record of ant 
        ant(:,i)=[ant(:,i);next_node];
        next_edge=find(map(:,1)==current_node & map(:,2)==next_node);
        ant_edge(:,i)=[ant_edge(:,i);next_edge];
        
        % Updates its pheromone trail.
        map(local_routing_index,4)=map(local_routing_index,4)+p;
        
        % Check if it reaches the destination point. 
        if next_node==destination
        % If yes, this ant will "retrace" its trail and update the trail 
        % based on the evaluation of the trail.
            map(:,ant_edge)=map(:,ant_edge)+p*2;
        
        % This ant "dies" after retracing. Its corresponding data in the 
        % ant edge matrix will be copied to a dead ant matrix and deleted.
            route(:,i)=ant_edge(:,i);
            ant_edge(:,i)=[];
            ant(:,i)=[];
        
        end
        
        % After looping through the ant matrix, apply pheromone evaporation to the
        % map.
        map(:,4)=map(:,4)*(1-k);
    end
    step(i)=step(i)+1;
    
    % checking while loop termination condition: if there's no ants alive on
    % the map, terminate the loop
end

% check the trail table and find the shortest route
% end










