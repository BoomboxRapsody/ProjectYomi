CSPROJ="osu.Game/osu.Game.csproj"
SLN="osu.sln"

dotnet remove $CSPROJ package ppy.osu.Game.Resources;
dotnet sln $SLN add ../ProjectYomi-resources/osu.Game.Resources/osu.Game.Resources.csproj
dotnet add $CSPROJ reference ../ProjectYomi-resources/osu.Game.Resources/osu.Game.Resources.csproj

SLNF="osu.Desktop.slnf"
TMP=$(mktemp)
jq '.solution.projects += ["../ProjectYomi-resources/osu.Game.Resources/osu.Game.Resources.csproj"]' $SLNF > $TMP
mv -f $TMP $SLNF
