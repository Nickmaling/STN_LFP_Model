function [newlead] = rotlalil(lead,angle)
    newlead = bsxfun(@plus,bsxfun(@minus,lead,lead(1,:))*findRotMat(angle,0,0),lead(1,:));
end

