classdef myGit
    % MYGIT - custom git commands set
    % ==========================================
    %
    %   FIRST (clone)
    %       CLONE(REPONAME): git clone https://github.com/kihongChoi/REPONAME
    %
    %   SECOND (edit and push)
    %       add: git add filename.m
    %       push: git push
    %       COMMIT: git commit -m "MEMO"
    %       REBASE: git pull --rebase origin master
    %
    %   THIRD (check and fix)
    %       LOG: git log --pretty=oneline
    %       RESET: git fetch --all, git reset --hard origin/master
    
 
    properties
    end
    
    methods (Static)
        function clone(repoName)
            eval(['git clone https://github.com/kihongChoi/', repoName]);
        end
        
        function commit(memo)
            eval(['git commit -m "', memo, '";']);
        end
        
        function add2push(memo)
            eval(['git add ''*.m''']);
            eval(['git commit -m "', memo, '";']);
            eval(['git push');
        end
        
        function rebase()
            git pull --rebase origin master
        end
        
        function log()
            git log --pretty=oneline
        end
        
        function reset()
            git fetch --all
            git reset --hard origin/master
        end
    end
    
end

