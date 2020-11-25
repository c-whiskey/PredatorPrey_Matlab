function[] = PredatorPrey_Model(InitpopDensity, lifeSpan, foodDecay, foodRespawnRate, localisationQuadrant)


%% Draft 3 - 29 sep  
%Chris White - Q4
%  TO DO: 
% -> Code tidyup 
% -> line 264 - Inifite whie loop caused by overpopulation - need to find a
%        better work around

%% Valid input parameters
%  - InitpopDensity [0 1]
%  - lifeSpan [0 15]
%  - foodDecay [0 0.1]
%  - foodRespawnRate [0 500]
%  - localisationQuadrant [0 4]


%% Setting variables
frameRate = 20;
percentage = InitpopDensity * 40000;

xy = zeros(200,200); % create grid
predMask = zeros(200,200); % Used to keep track of which parasites have moved
foodMask = zeros(200,200); %Used to keep track of food count

foodVal = 20;
fCounter = 0; % Various counters used throughout program
pCounter = 0;

foodRespawnCounter = 0;

%Open video file
outputFilename = input('Please enter a filename:','s');
filename = strcat(outputFilename,'.avi');
writerObj = VideoWriter(filename);
writerObj.FrameRate = frameRate;
open(writerObj);




%% Handling invalid inputs
if InitpopDensity < 0 || InitpopDensity > 1
    error('Error: Enter a population density between 0 & 1')
elseif lifeSpan < 0 || lifeSpan > 15
    error('Error: Enter a value for fOne between 0 & 15')
elseif foodDecay < 0 || foodDecay > 0.1
    error('Error: Enter a value for fTwo between 0 & 0.1')
elseif foodRespawnRate < 0 || foodRespawnRate > 500
    error('Error: Enter a value for fThree between 0 & 500')
elseif localisationQuadrant < 0 || localisationQuadrant > 4
    error('Error: Enter one of the following values for food localisation\n%s',...
        '1 - Upper right quadrant','2 - Upper left quadrant',...
        '3 - Lower left quadrant','4 - Lower right quadrant'...
        ,'0 - Use entire grid')
end

    


%% Positioning respawn of food sources (for localisation)
if localisationQuadrant == 0 % All quadrants
    mStart = 1;
    mStop = 200;
    nStart = 1;
    nStop = 200;
elseif localisationQuadrant == 1 % Upper right
    mStart = 100;
    mStop = 200;
    nStart = 100;
    nStop = 200;
elseif localisationQuadrant == 2 % Upper left
    mStart = 100;
    mStop = 200;
    nStart = 1;
    nStop = 100;

elseif localisationQuadrant == 3 % Lower left
    mStart = 1;
    mStop = 100;
    nStart = 1;
    nStop = 100;    
elseif localisationQuadrant == 4 % Lower left
    mStart = 1;
    mStop = 100;
    nStart = 100;
    nStop = 200;  
end


%% Initial population of grid

while fCounter < percentage/2
    x = randi([1 200]);
    y = randi([1 200]);
    
    if xy(x,y) == 0
        xy(x,y) = foodVal;
        fCounter = fCounter + 1;
    end
    
end

while pCounter < percentage/2
    x = randi([1 200]);
    y = randi([1 200]);
    
    if xy(x,y) == 0
        xy(x,y) = lifeSpan;
        pCounter = pCounter + 1;
    end
    
end

%% Plot figure
k = figure(1);
h = pcolor(xy);
title('Predator / food interactions in a 200 x 200 grid');
axis off;
set(h, 'EdgeColor', 'none');

% cheeky way of forcing values to be a certain colour
my_map = [1,1,1; %white
          1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; % red
          1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; 1,0,0; % red
          0,0,1]; % blue 
colormap(my_map)
hold on; % Do i need this here?
myLegend = zeros(2, 1); % For custom legend.
myLegend(1) = plot(NaN,NaN,'.r');
myLegend(2) = plot(NaN,NaN,'.b'); 

legend(myLegend, 'Predator','Food','Location','northeastoutside');

%Text box for displaying current step
MyBox = uicontrol('style','text');
set(MyBox,'Position',[430,200,100,100])



%colorbar('Ticks',[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]) % remove this later 



%% Main movement loop
for i = 1:200 % i need a better parameter to move towards
    
    set(MyBox,'String',strcat('Step: ',int2str(i) ))
    foodMask = xy == 20; % Creates a mask containing all food locations
                         % Used for counting num of food sources
    
    for m = 1:length(xy) % m rows (horizontal)
        
        for n = 1:length(xy) % n colums (vertical)
            
            u = rand;  % Sampling from a uniform distribution
            
            %check for empty cell
            if xy(m,n) == 0
                %Do nothing, Basically shortcircuting loop.   
            
            %check for food
            elseif xy(m,n) == foodVal % remove food agent if u < fTwo
            
                if u < foodDecay % fTwo value determined by user between [0 0.1]
                    xy(m,n) = 0;
                end
                
            %Check for parasite
            elseif xy(m,n) > 0 && xy(m,n) <= lifeSpan && predMask(m,n) == 0 % fOne lifespan of parasite [0 15]
                % note if predMask(m,n) == 1 then the parasite in the corresponding cell has
                % already moved once this round. (Used to prevent double moves)
                
                % choose a direction for parasite to move
                if (0 <= u) && (u <= 0.25)
                    dir = 1; % dir = 1 = north
                elseif  (0.25 < u) && (u <= 0.5)
                    dir = 2; % dir = 2 = east
                elseif (0.5 < u) && (u <= 0.75)
                    dir = 3; % dir = 3 = south
                else
                    dir = 4; % dir = 4 = west
                end
                
                % Check if destination is a wall (prevents indexing errors)
                % if so, move does not take place 
                % & next iteration of loop is started
                if m == 1 && dir == 1
                    continue % break loop early (ie do not move parasite)
                elseif m == 200 && dir == 3
                    continue
                elseif n == 1 && dir == 4
                    continue
                elseif n == 200 && dir == 2
                    continue
                end
                              
                              
                %Check if destination block is empty or has food
                %parasite then moves into the destination cell
                %if destination cell contained food 
                %a new parasite spawns in the original cell. 
                if dir == 1 && (xy(m-1,n) == 0 || xy(m-1,n) == foodVal) % xy(m-1,n) = north
                    if xy(m-1,n) == foodVal 
                        xy(m-1,n) = xy(m,n) - 1; %set new position and reduce life
                        xy(m,n) = lifeSpan; % Spawn new parasite at original position
                        
                        predMask(m-1,n) = 1; 
                        predMask(m,n) = 1;
                    else % cell is not food - must be empty
                        xy(m-1,n) = xy(m,n) - 1; % set new position and reduce life
                        xy(m,n) = 0; % original position is now empty
                        
                        predMask(m-1,n) = 1;
                    end
                elseif dir == 2 && (xy(m,n+1) == 0 || xy(m,n+1) == foodVal) % xy(m,n+1) = east
                    if xy(m,n+1) == foodVal
                        xy(m,n+1) = xy(m,n) - 1;
                        xy(m,n) = lifeSpan;
                        
                        predMask(m,n+1) = 1; 
                        predMask(m,n) = 1;
                    else
                        xy(m,n+1) = xy(m,n) - 1;
                        xy(m,n) = 0;
                        
                        predMask(m,n+1) = 1;
                    end
                elseif dir == 3 && (xy(m+1,n) == 0 || xy(m+1,n) == foodVal) % xy(m+1,n) = south
                    if xy(m+1,n) == foodVal
                        xy(m+1,n) = xy(m,n) - 1;
                        xy(m,n) = lifeSpan;
                               
                        predMask(m+1,n) = 1; 
                        predMask(m,n) = 1;
                    else
                        xy(m+1,n) = xy(m,n) - 1;
                        xy(m,n) = 0;
                        
                        predMask(m+1,n) = 1;
                    end
                    
                elseif dir == 4 && (xy(m,n-1) == 0 || xy(m,n-1) == foodVal) % xy(m,n-1) = west
                    if xy(m,n-1) == foodVal
                        xy(m,n-1) = xy(m,n) - 1;
                        xy(m,n) = lifeSpan;

                        predMask(m,n-1) = 1; 
                        predMask(m,n) = 1;
                    else
                        xy(m,n-1) = xy(m,n) - 1;
                        xy(m,n) = 0;
                        
                        predMask(m,n-1) = 1; 
                    end
                else
                    xy(m,n) = xy(m,n) - 1; % if the parasite is not able to move (surrounded on all sides) decrease health by 
                end
                
            end
            
        end
        
    end
  
    
   testCounter = 0;
    %Repopulate food supply after all agents have been processed in current step 
    while foodRespawnCounter < foodRespawnRate % do the f3 bit
        x = randi([mStart mStop]); % dimensions specified by user (used for localisation)
        y = randi([nStart nStop]); 
        
        if xy(x,y) == 0
            xy(x,y) = foodVal;
            foodRespawnCounter = foodRespawnCounter + 1;
        end
        
        %% Really hacky way to deal with infinite loop issue caused by overpopulation
        % if there isn't enough room to respawn the loop never ends
        % Come back to this
        testCounter = testCounter + 1;
        if testCounter > 3*foodRespawnRate 
            break
        end
        
    end 
    foodRespawnCounter = 0; % reset for next loop
   
    %For population/step plot 
    predSum(i) = sum(predMask,'all');
    foodSum(i) = sum(foodMask,'all');
    
    step(i) = i;
    
    foodMask(:,:) = 0;
    predMask(:,:) = 0; % reset masks for next loop
    
    %Capture plot as image
    frame = getframe(k);
    writeVideo(writerObj,frame);

    %Upate plot
    h.CData = xy;
    drawnow;
    
    
end % loop end

close(writerObj);

%% pred/prey plot
figure(2);
hold on
 % gotta swap the colours for the red and blue
plot(step,predSum,'color','red');
plot(step,foodSum,'color','blue');
legend('Predator','Food');
xlabel('Step')
ylabel('Population')
title('Predator/food population in a 200 x 200 grid')



end 

