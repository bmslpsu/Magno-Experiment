for i=length(position_data)-1
   diff(i)=position_data(i+1)-position_data(i);
end
plot(diff)