classdef myGit
    % MYGIT - custom git commands set
    % ==========================================
    %
    %   FIRST (clone)
    %       CLONE(REPONAME): git clone https://github.com/kihongChoi/REPONAME
    %       LOG: git log --pretty=oneline
    %
    %   SECOND (edit and push)
    %       add: git add filename.m
    %       push: git push
    %       COMMIT: git commit -m "MEMO"
    %       REBASE: git pull --rebase origin master
 
    properties
    end
    
    methods (Static)
        function clone(repoName)
            eval(['git clone https://github.com/kihongChoi/', repoName]);
        end
        
        function commit(memo)
            eval(['git commit -m "', memo, '";']);
        end
        
        function rebase()
            git pull --rebase origin master
        end
        
        function log()
            git log --pretty=oneline
        end
    end
    
end

