function sol = DWFluidModel()
    clc; clear;
    
    global g d C K N RTT;
    global w;
    N = 4;
    g = 1.0/16;
    d = 10;
    C = 50;
    K = 10;
    RTT = 10;
    
    w = ones(1, N);
    hist = zeros(1, N+4);
    for i = 1:N
        w(i) = i/((N+1));
        hist(i) = 200*rand();
    end
    
    
    hist(N+1) = 1;
    hist(N+4) = d;
    initial_step = 0.1;
    max_step = 1;
    
    options = ddeset('MaxStep', max_step, 'InitialStep', initial_step);
    %sol = dde23(@pfc, RTT, [0, 1, 0, 0, d], [0, 10000],  options);
    sol = dde23(@pfc, RTT, hist, [0, 10000],  options);
    %t = sol.x;
    %s1i = sol.y(1,:);
    for i = 1:N
        file = sprintf('cwnd-%d.txt',i);
        fid = fopen(file, 'wt');
        %fprintf(fid, '%d | %d\n', i, size(sol.x, 2));
        for j = 1:size(sol.x, 2)
            fprintf(fid, '%f,%f\n', sol.x(1, j), sol.y(i, j));
        end
        fclose(fid);
    end
    
    figure
    set(gca,'LooseInset',get(gca,'TightInset'), 'FontWeight','bold');
    %set(gca,'linewidth',6)
    %axes('linewidth',4, 'box', 'off');
    %set(gcf,'Units','centimeters','Position',[10 10 6.096 4.064]);
    p = plot (sol.x / 100, sol.y(1:N, :), 'linewidth', 1.5);
    
    xlabel('Seconds');
    ylabel('CWND(MSS)');
    grid on;
    
    legend(p(1:2),'Flow 0','Flow 1');
    ah=axes('position',get(gca,'position'),...
            'visible','off');
    legend(ah,p(3:4),'Flow 2','Flow 3','location','west');
   %legend('Flow 0','Flow 1','Flow 2','Flow 3','Flow 4');
    
    
    %hold on
    %plot (t, sol.y(2, :), 'r');
    %hold on
    %plot (t, sol.y(3, :), 'g');
    %hold on
    %plot (t, sol.y(4, :), 'r');
    %hold on
    %plot (t, sol.y(5, :), '.');
 
    %axis([1000 1100 0 1]); 
end

function dy = pfc(t,y,Z)
    global g C K N;
    global w;
    dy = zeros(5, 1);
    
    % y
    % y1 = W(t)
    % y2 = alpha(t)
    % y3 = q(t)
    % y4 = p(t)
    % y5 = R(t)
    %
    sumW = 0;
    for i = 1:N
        %dy(1) = 1/y(5) - y(1)*y(2)*(Z(4, 1) >= 1)/(2*y(5));
        dy(i) = w(i)/y(N+4) - y(i)*y(N+1)*(Z(N+3, 1) >= 1)/(2*y(N+4));
        sumW = sumW + y(i);
    end
    %dy(2) = g*((Z(4, 1) >= 1) - y(2))/y(5);
    dy(N+1) = g*((Z(N+3, 1) >= 1) - y(N+1))/y(N+4);
    %dy(3) = N*y(1)/y(5) - C;
    dy(N+2) = sumW/y(N+4) - C;
    if(dy(N+2) < 0 && y(N+2) <= 0)
        dy(N+2) = 0;
    end
    %dy(4) = dy(3)/K;
    dy(N+3) = dy(N+2)/K;
    %dy(5) = dy(3)/C;
    dy(N+4) = dy(N+2)/C;
    
    %fprintf('%g W=%g alpha=%g q=%g p=%g R=%g dw=%g da=%g dq=%g\n', t, y(1), y(2), y(3), y(4), y(5), dy(1), dy(2), dy(3));

end