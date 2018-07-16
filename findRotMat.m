
function Rmat = findRotMat(xan,yan,zan)

    x=[1 0 0; 0 cos(xan*pi/180) -sin(xan*pi/180); 0 sin(xan*pi/180) cos(xan*pi/180)];
    y=[cos(yan*pi/180) 0 sin(yan*pi/180); 0 1 0; -sin(yan*pi/180) 0 cos(yan*pi/180)];	
    z=[cos(zan*pi/180) -sin(zan*pi/180) 0; sin(zan*pi/180) cos(zan*pi/180) 0; 0 0 1];

    Rmat = x*y*z;
end