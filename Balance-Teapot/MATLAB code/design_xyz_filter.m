function design_xyz_filter
% Copyright 2012 - 2015 The MathWorks, Inc.

    d = dir('iPhone_accelerometer_input_*.txt');
    [~,newest]=max([d.datenum]);
    newest = newest(1); % in case there are ties
    input_file_name = d(newest).name;
    iphone_accelerometer = load(input_file_name);
    x = iphone_accelerometer(:,1);
    y = iphone_accelerometer(:,2);
    z = iphone_accelerometer(:,3);

    Fs   = 100;  % Sampling Frequency (Hz)
    FilterOrders = [2 4 8];
    CutoffFrequencies = [1 2.5 5 10];
    FontSize = 14;

    for m=1:length(CutoffFrequencies)
%         figure(m);
%         set(m,'units','normalized','outerposition',[0 0 1 1]);
        clf;axes_handles = zeros(1,length(FilterOrders));
        Fc = CutoffFrequencies(m);
        for n=1:length(FilterOrders)
            FilterOrder = FilterOrders(n);
            h = fdesign.lowpass('n,f3db', FilterOrder, Fc, Fs);
            designMethod = 'butter';
            Hd = design(h, designMethod);
            
            SOSMatrix = Hd.sosMatrix;
            ScaleValues = Hd.ScaleValues;
            reset_filter = true;
            Structure = 'Direct form II transposed';
            enable_filter = true;
            xyz_out = xyz_filter(x,y,z,...
                                 reset_filter,...
                                 Structure,...
                                 SOSMatrix,...
                                 ScaleValues,...
                                 enable_filter);
            x_out(:,n,m) = xyz_out(:,1);
            y_out(:,n,m) = xyz_out(:,2);
            z_out(:,n,m) = xyz_out(:,3);
            t = (0:length(x)-1)/Fs;
%             axes_handles(n) = subplot(length(FilterOrders),1,n);
%             plot(t,xyz_out(:,1),'r',...
%                  t,xyz_out(:,2),'g',...
%                  t,xyz_out(:,3),'b',...
%                  t,x,'r--',...
%                  t,y,'g--',...
%                  t,z,'b--');
%             set(gca,'FontSize',FontSize);
%             set(gcf,'Name',[num2str(Fc),' Hz Cutoff Frequency'],...
%                     'NumberTitle','off');
%             grid on
%             legend('x out','y out','z out',...
%                    'x in','y in','z in')
%             xlabel('Time (s)')
%             title([' Design method = ',designMethod,...
%                    ', Filter order = ',int2str(FilterOrder),...
%                    ', Cutoff Frequency = ',num2str(Fc),' Hz'])
%             drawnow
        end
%         linkaxes(axes_handles);
%         zoom on
%         figure(gcf)
    end

    % Plot vs cutoff frequencies
    axes_handle(1) = subplot(3,2,1);
    plot(t,x,'r');
    hold;
    plot(t,x_out(:,1,2),'r--');

    set(gca,'FontSize',FontSize);
    set(gcf,'Name','Compare cutoff frequencies',...
        'NumberTitle','off');
    grid on;
    legend('x in','x out');
    xlabel('Time (s)');
    title([' Design method = ',designMethod,...
        ', Filter order = ',int2str(FilterOrders(1)),...
        ', Cutoff Frequency = ',num2str(CutoffFrequencies(2)),' Hz']);
    xlim([min(t) max(t)]);

    axes_handle(2) = subplot(3,2,2);
    plot(t,x,'r');
    hold;
    plot(t,x_out(:,1,4),'r--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('x in','x out');
    xlabel('Time (s)');
    title([designMethod,' filter'...
        ', Filter order = ',int2str(FilterOrders(1)),...
        ', Cutoff frequency = ',num2str(CutoffFrequencies(end)),' Hz']);

    linkaxes(axes_handle(1:2));

    axes_handle(3) = subplot(3,2,3);
    plot(t,y,'g');
    hold;
    plot(t,y_out(:,1,2),'g--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('y in','y out');
    xlabel('Time (s)');
    xlim([min(t) max(t)]);

    axes_handle(4) = subplot(3,2,4);
    plot(t,y,'g');
    hold;
    plot(t,y_out(:,1,4),'g--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('y in','y out');
    xlabel('Time (s)');

    linkaxes(axes_handle(3:4));

    axes_handle(5) = subplot(3,2,5);
    plot(t,z,'b');
    hold;
    plot(t,z_out(:,1,2),'b--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('z in','z out');
    xlabel('Time (s)');
    xlim([min(t) max(t)]);

    axes_handle(6) = subplot(3,2,6);
    plot(t,z,'b');
    hold;
    plot(t,z_out(:,1,4),'b--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('z in','z out');
    xlabel('Time (s)');

    linkaxes(axes_handle(5:6));

    % Plot vs filter order
    figure;
        axes_handle(1) = subplot(3,2,1);
    plot(t,x,'r');
    hold;
    plot(t,x_out(:,1,2),'r--');

    set(gca,'FontSize',FontSize);
    set(gcf,'Name','Compare filter order',...
        'NumberTitle','off');
    grid on;
    legend('x in','x out');
    xlabel('Time (s)');
    title([' Design method = ',designMethod,...
        ', Filter order = ',int2str(FilterOrders(1)),...
        ', Cutoff Frequency = ',num2str(CutoffFrequencies(2)),' Hz']);
    xlim([min(t) max(t)]);

    axes_handle(2) = subplot(3,2,2);
    plot(t,x,'r');
    hold;
    plot(t,x_out(:,end,2),'r--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('x in','x out');
    xlabel('Time (s)');
    title([designMethod,' filter'...
        ', Filter order = ',int2str(FilterOrders(end)),...
        ', Cutoff frequency = ',num2str(CutoffFrequencies(2)),' Hz']);

    linkaxes(axes_handle(1:2));

    axes_handle(3) = subplot(3,2,3);
    plot(t,y,'g');
    hold;
    plot(t,y_out(:,1,2),'g--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('y in','y out');
    xlabel('Time (s)');
    xlim([min(t) max(t)]);

    axes_handle(4) = subplot(3,2,4);
    plot(t,y,'g');
    hold;
    plot(t,y_out(:,end,2),'g--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('y in','y out');
    xlabel('Time (s)');

    linkaxes(axes_handle(3:4));

    axes_handle(5) = subplot(3,2,5);
    plot(t,z,'b');
    hold;
    plot(t,z_out(:,1,2),'b--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('z in','z out');
    xlabel('Time (s)');
    xlim([min(t) max(t)]);

    axes_handle(6) = subplot(3,2,6);
    plot(t,z,'b');
    hold;
    plot(t,z_out(:,end,2),'b--');

    set(gca,'FontSize',FontSize);
    grid on;
    legend('z in','z out');
    xlabel('Time (s)');

    linkaxes(axes_handle(5:6));
   
end