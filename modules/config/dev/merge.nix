{config, ...}:
{
  flake.modules.homeManager.dev =
    {pkgs, ...}: 
    {
       programs.git = {
        settings = {
          merge ={
            conflictstyle = "zdiff3";
            tool = "diffview";
          };

          mergetool = {
            prompt = false;
            keepBackup = false;
            "diffview" = {
              cmd = ''nvim -n -c 'DiffviewOpen' "$MERGE"'';
              layout = "LOCAL,BASE,REMOTE / MERGED";
            };
          };

          pull = {
            # Avoid creating merge commits in non-main branches.
            rebase = true;
          };

          rebase = {
            autoStash = true;
            autosquash =  true;
            forkpoint = false;
          };
        };
      };
    };
}
