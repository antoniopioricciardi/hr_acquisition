classdef callback_examples
    %
    %   Class:
    %   labchart.streaming.callback_examples
    
    properties
        Property1
    end
    
    methods (Static)
        function nValidSamples(stream_obj,h_doc)
            %
            %   labchart.streaming.callback_examples.nValidSamples
            %
            %   h_doc : labchart.document
            
            persistent h_tic
            
            %Output every 5 seconds
            if isempty(h_tic) || toc(h_tic) > 5
                h_tic = tic;
                fprintf('# of valid seconds in buffer = %0.2f\n',stream_obj.n_seconds_valid)
            end
        end
        function averageSamplesAddComment(stream_obj,h_doc)
         	persistent h_tic
            
            %Output every 5 seconds
            if isempty(h_tic) 
                h_tic = tic;
            else
                if toc(h_tic) > 5
                    h_tic = tic;
                    [data,time] = stream_obj.getData();
                    if length(data) ~= length(time)
                        fprintf(2,'WTF Jim!!! %d,%d\n',length(data),length(time))
                    end
                    h_doc.addComment(sprintf('Mean %g starting at %g',mean(data),time(1)));
                end
            end
        end
        function myStreamingCallback(obj, ~)
            seg = obj.new_data;                          % grab latest samples
            obj.user_data.buf = [obj.user_data.buf; seg];  % accumulate
        end

        function store_new_data(obj, ~)
            %STORE_NEW_DATA Append latest streaming segment to obj.user_data.buffer.
            %   This callback can be assigned to the ui_streamed_data2 object via
            %   s1.callback = @store_new_data;  It ensures the user_data property
            %   contains a struct with a field named 'buffer' used to accumulate
            %   received segments. Empty segments are ignored.
            obj.user_data = obj.new_data;
            if isempty(obj.user_data)
                return;
            end
            %mat2str(size(obj.new_data))
        end

    end
end

