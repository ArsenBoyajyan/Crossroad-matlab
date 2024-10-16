clear;
level = input("difficult? (y/n or m for manual): ", "s");
while true
    switch level
        case "n"
            n = randi([1,6]);
            random_range = [-2, 2];
            car_step = 0.01;
            break;
        case "y"
            n = randi([7,12]);
            random_range = [-1, 1];
            car_step = 0.02;
            break;
        case "m"
            n = input("number of cars(1-10): ");
            while true
                if ~(n>=1 && n <=10)
                    n = input("wrong input: ");
                else
                    break;
                end
            end

            p = input("probability that car will ignore traffic light(0-1): ");
            while true
                if ~(p>=0 && p <=1)
                    p = input("wrong input: ");
                else
                    if p == 0
                        random_range = [2, 3]; %so we do not get 0
                    else
                        random_range = [1, fix(1/p)];
                    end
                    break;
                end
            end

            speed = input("car speed(fast, slow): ", "s");
            while true
                if ~(speed == "fast" || speed == "slow")
                    speed = input("wrong input: ", "s");
                else
                    if speed == "fast"
                        car_step = 0.02;
                    else
                        car_step = 0.01;
                    end
                    break;
                end
            end
            break;
        otherwise
            level = input("wrong input: ", "s");
    end
end

w = input("road width (0.5-2): ");
while true
    if ~(w >= 0.5 && w <= 2)
        w = input("wrong input: ");
    else
        break;
    end
end

y_time = input("input yellow light time in seconds (at least 0.1): ");
while true
    if ~y_time>=0.1
        disp("wrong input: ")
    else
        break;
    end
end
y_time = round(y_time, 1);

g_time = input("input green light time in seconds (at least 0.1): ");
while true
    if ~g_time>=0.1
        disp("wrong input: ")
    else
        break;
    end
end
g_time = round(g_time, 1);

%initializing
axis([-3 3 -3 3])
hold on;
roads = draw_roads(w, 6);
traffic_light_status = change_light_colors(4, w);

%defining number of cars in each side
leftN = randi([0 fix(n/2)]); n = n - leftN;
rightN = randi([0 fix(n/2)]); n = n - rightN;
downN = randi([0  fix(n/2)]); n = n - downN;
upN = n;

left_cars = create_car_arrays("left", w, leftN);
right_cars = create_car_arrays("right", w, rightN);
down_cars = create_car_arrays("down", w, downN);
up_cars = create_car_arrays("up", w, upN);

%generate plates
arr = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"...
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J"...
    "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T"...
    "U", "V", "W", "X", "Y", "Z"];
plates = generate_plates(arr, 6, leftN + rightN + downN + upN);
left_plates = plates(1:leftN);
plates = plates(leftN + 1:length(plates));
right_plates = plates(1:rightN);
plates = plates(rightN + 1:length(plates));
down_plates = plates(1:downN);
plates = plates(downN + 1:length(plates));
up_plates = plates(1:upN);

not_stopped_cars = [];

i = 0; %step counter for traffic lights
did_stop = zeros(4, max([leftN, rightN, downN, upN])); %indicate weather car followed the traffic light or not
finished = [0 0 0 0]; 



%main animation part
while(true)
    for j = 1:(max([leftN, rightN, downN, upN]))
        if j <= leftN
            if traffic_light_status==4 %green light
                left_cars(j).Position = left_cars(j).Position + [car_step 0 0 0];
            elseif (left_cars(j).Position(1) > -w/2-0.51) && (left_cars(j).Position(1) < -w/2-0.49) %near the edge
                if randi(random_range) == 1 && did_stop(1, j) ~= 1
                    did_stop(1, j) = -1;
                    not_stopped_cars = cat(2, not_stopped_cars, left_plates(j));
                    left_cars(j).Position = left_cars(j).Position + [car_step 0 0 0];
                else
                    if did_stop(1, j) == -1
                        left_cars(j).Position = left_cars(j).Position + [car_step 0 0 0];
                    else
                        did_stop(1, j) = 1;
                    end
                end
            elseif (left_cars(j).Position(1) > -w/2-0.52) %passed
                left_cars(j).Position = left_cars(j).Position + [car_step 0 0 0];
            elseif j > 1 && (left_cars(j-1).Position(1)-0.1 > left_cars(j).Position(1)+left_cars(j).Position(3)) %no stopped car ahead
                left_cars(j).Position = left_cars(j).Position + [car_step 0 0 0];
            elseif j == 1
                left_cars(j).Position = left_cars(j).Position + [car_step 0 0 0];
            end
        end

        if j <= rightN
            if traffic_light_status==4 %green light
                right_cars(j).Position = right_cars(j).Position - [car_step 0 0 0];
            elseif (right_cars(j).Position(1) > w/2+0.18) && (right_cars(j).Position(1) < w/2+0.22) %near the edge
                if randi(random_range) == 1 && did_stop(2, j) ~= 1
                    did_stop(2, j) = -1;
                    not_stopped_cars = cat(2, not_stopped_cars, right_plates(j));
                    right_cars(j).Position = right_cars(j).Position - [car_step 0 0 0];
                else
                    if did_stop(2, j) == -1
                        right_cars(j).Position = right_cars(j).Position - [car_step 0 0 0];
                    else
                        did_stop(2, j) = 1;
                    end
                end
            elseif (right_cars(j).Position(1) < w/2+0.22) %passed
                right_cars(j).Position = right_cars(j).Position - [car_step 0 0 0];
            elseif j > 1 && (right_cars(j-1).Position(1)+right_cars(j-1).Position(3))+0.1 < right_cars(j).Position(1) %no stopped car ahead
                right_cars(j).Position = right_cars(j).Position - [car_step 0 0 0];
            elseif j == 1
                right_cars(j).Position = right_cars(j).Position - [car_step 0 0 0];
            end
        end

        if j <= downN
            if traffic_light_status==2 %green light
                down_cars(j).Position = down_cars(j).Position + [0 car_step 0 0];
            elseif (down_cars(j).Position(2) < -w/2-0.58) && (down_cars(j).Position(2) > -w/2-0.62) %near the edge
                if randi(random_range) == 0 && did_stop(3, j) ~= 1
                    did_stop(3, j) = -1;
                    not_stopped_cars = cat(2, not_stopped_cars, down_plates(j));
                    down_cars(j).Position = down_cars(j).Position + [0 car_step 0 0];
                else
                    if did_stop(3, j) == -1
                        down_cars(j).Position = down_cars(j).Position + [0 car_step 0 0];
                    else
                        did_stop(3, j) = 1;
                    end
                end
            elseif (down_cars(j).Position(2) > -w/2-0.58) %passed
                down_cars(j).Position = down_cars(j).Position + [0 car_step 0 0];
            elseif j > 1 && (down_cars(j-1).Position(2)-0.1 > down_cars(j).Position(2)+down_cars(j).Position(4)) %no stopped car ahead
                down_cars(j).Position = down_cars(j).Position + [0 car_step 0 0];
            elseif j == 1
                down_cars(j).Position = down_cars(j).Position + [0 car_step 0 0];
            end
        end

        if j <= upN
            if traffic_light_status==2 %green light
                up_cars(j).Position = up_cars(j).Position - [0 car_step 0 0];
            elseif (up_cars(j).Position(2) > w/2+0.18) && (up_cars(j).Position(2) < w/2+0.22) %near the edge
                if randi(random_range) == 0 && did_stop(4, j) ~= 1
                    did_stop(4, j) = -1;
                    not_stopped_cars = cat(2, not_stopped_cars, up_plates(j));
                    up_cars(j).Position = up_cars(j).Position - [0 car_step 0 0];
                else
                    if did_stop(4, j) == -1
                        up_cars(j).Position = up_cars(j).Position - [0 car_step 0 0];
                    else
                        did_stop(4, j) = 1;
                    end
                end
            elseif (up_cars(j).Position(2) < w/2+0.22) %passed
                up_cars(j).Position = up_cars(j).Position - [0 car_step 0 0];
            elseif j > 1 && (up_cars(j-1).Position(2)+up_cars(j-1).Position(4))+0.1 < up_cars(j).Position(2) %no stopped car ahead
                up_cars(j).Position = up_cars(j).Position - [0 car_step 0 0];
            elseif j == 1
                up_cars(j).Position = up_cars(j).Position - [0 car_step 0 0];
            end
        end
    end

    %check if traffic light colors need to be changed
    if traffic_light_status == 2 || traffic_light_status == 4 %green/red light
        if mod(i, 50 * g_time) == 0
            traffic_light_status = change_light_colors(traffic_light_status, w); i = 0;
        end
    elseif mod(i, 50 * y_time) == 0 %yellow light
            traffic_light_status = change_light_colors(traffic_light_status, w); i = 0;
    end

    if(did_crash(left_cars, right_cars, down_cars, up_cars))
        did_lose = true;
        break;
    end

    if leftN == 0 
        finished(1) = 1;
    elseif left_cars(leftN).Position(1) > w/2 %all left_cars passed
        finished(1) = 1;
    end
    if rightN == 0
        finished(2) = 1;
    elseif right_cars(rightN).Position(1) < -w/2-0.5 %all right_cars passed
        finished(2) = 1;
    end
    if downN == 0 
        finished(3) = 1;
    elseif down_cars(downN).Position(2) > w/2 %all down_cars passed
        finished(3) = 1;
    end
    if upN == 0
        finished(4) = 1;
    elseif up_cars(upN).Position(2) < -w/2-0.5 %all up_cars passed
        finished(4) = 1;
    end
    if sum(finished) == 4 %all the cars passed, no crash accured
        did_lose = 0;
        break;
    end

    i = i + 1;
    pause(0.02)
end

%winning
if ~did_lose
    disp("You Won")
    rectangle("Position",[-3 -3 6 6],"FaceColor","g")
    text(-0.5,0,"You Won")
end

%losing
if did_lose
    disp("You Lost")
    rectangle("Position",[-3 -3 6 6],"FaceColor","r")
    text(-0.5,0,"You Lost")
end

%cars that violated traffic light rool
if ~isempty(not_stopped_cars)
    disp("the following cars violated the traffic light rules:")
    disp(not_stopped_cars)
else
    disp("All the cars followed the traffic light")
end

clear;

function a = did_crash(arr1, arr2, arr3, arr4)
if sum(sum(rectint([cat(1,arr1.Position)], [cat(1,arr2.Position)])))
    a = true;
elseif sum(sum(rectint([cat(2,arr2.Position)], [cat(1,arr3.Position)])))
    a = true;
elseif sum(sum(rectint([cat(1,arr3.Position)], [cat(1,arr4.Position)])))
    a = true;
elseif sum(sum(rectint([cat(1,arr4.Position)], [cat(1,arr1.Position)])))
    a = true;
elseif sum(sum(rectint([cat(1,arr1.Position)], [cat(1,arr3.Position)])))
    a = true;
elseif sum(sum(rectint([cat(1,arr4.Position)], [cat(1,arr2.Position)])))
    a = true;
else
    a = false;
end
end

function plates = generate_plates(arr, l, n)
if n ==1
    plates = [generate_plate(arr, l)];
else
    prev_plates = generate_plates(arr, l, n - 1);
    while true
        x = generate_plate(arr, l);
        if cat(2, x, prev_plates) == unique(cat(2, x, prev_plates))
            plates = cat(2, x, prev_plates);
            break
        end
    end
end
end

function plate = generate_plate(arr, l)
if l == 1
    plate = arr(randi([11, 36])) + " ";
else
    plate = generate_plate(arr, l - 1) + arr(randi([1, length(arr)]));
end
end

function a = draw_roads(w, l)
x = [w/2, l/2];
y = [w/2, w/2];
plot(x, y, "k", 'LineWidth', 2);
plot(y, x, "k", 'LineWidth', 2);
plot(-x, y, "k", 'LIneWidth', 2);
plot(x, -y, "k", 'LIneWidth', 2);
plot(-x, -y, "k", 'LIneWidth', 2);
plot(y, -x, "k", 'LIneWidth', 2);
plot(-y, -x, "k", 'LIneWidth', 2);
plot(-y, x, "k", 'LIneWidth', 2);

%splitting lignes
y = [0, 0];
for i = -l/2:0.5:-w/2
    if i+0.25<-w/2
        x = [i, i+0.25];
        plot(x, y, "k")
        plot(y, x, "k")
        plot(-x, y, "k")
        plot(y, -x, "k")
    end
    
end

a = 0;
end

function a = create_car_arrays(direction, w, n)
a = [rectangle('Position', [0 0 0 0])];
switch direction
    case "left"
        car_distance = -3;
    case "right"
        car_distance = 2.7;
    case "down"
        car_distance = -3;
    case "up"
        car_distance = 2.7;
end

x = zeros(1, n);  
y = zeros(1, n);

for i = 1:n
    switch direction
        case "left"
            length = rand.*(w/4)+0.1;
            width = length/2;
            y(i) = -w/8-0.1;
            rand_distance = rand + 2*length;
            x(i) = car_distance - rand_distance;
            car_distance = car_distance - rand_distance;
        case "right"
            length = rand.*(w/4)+0.1;
            width = length/2;
            y(i) = w/8;
            rand_distance = rand + 2 *length;
            x(i) = car_distance + rand_distance;
            car_distance = car_distance  + rand_distance;
        case "down"
            width = rand.*(w/4)+0.1;
            length = width/2;
            x(i) = w/8;
            rand_distance = rand + 2*width;
            y(i) = car_distance - rand_distance;
            car_distance = car_distance  - rand_distance;
        case "up"
            width = rand.*(w/4)+0.1;
            length = width/2;
            x(i) = -w/8-0.1;
            rand_distance = rand + 3*width;
            y(i) = car_distance + rand_distance;
            car_distance = car_distance  + rand_distance;
    end
    
    a(i) =rectangle('Position',[x(i) y(i) length width],'EdgeColor','k','FaceColor',random_color());
end

end

function a = change_light_colors(traffic_light_status, w)
t = 0:1/50:2*pi;
x = 0.1*cos(t) + w/2;
y = 0.1*sin(t) + w/2;
switch traffic_light_status
    case 1
        patch(x,y,'red');
        patch(x,-y,'green');
        patch(-x,y,'green');
        patch(-x,-y,'red');
        traffic_light_status = 2;
    case 2
        patch(x,y,"y");
        patch(x,-y,"y");
        patch(-x,y,"y");
        patch(-x,-y,"y");
        traffic_light_status = 3;
    case 3
        patch(x,y,'green');
        patch(x,-y,'red');
        patch(-x,y,'red');
        patch(-x,-y,'green');
        traffic_light_status = 4;
    case 4
        patch(x,y,"y");
        patch(x,-y,"y");
        patch(-x,y,"y");
        patch(-x,-y,"y");
        traffic_light_status = 1;
end
a = traffic_light_status;
end

function a = random_color()
x = randi([1, 7]);
switch x
    case 1
        a = "r";
    case 2
        a = "g";
    case 3
        a = "b";
    case 4
        a = "c";
    case 5
        a = "m";
    case 6
        a = "y";
    case 7
        a = "k";
end
end
