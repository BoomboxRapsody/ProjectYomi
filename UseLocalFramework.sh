#!/bin/sh

# Run this script to use a local copy of ProjectYomi-framework rather than fetching it from nuget.
# It expects the osu-framework directory to be at the same level as the osu directory
#
# https://github.com/ppy/osu-framework/wiki/Testing-local-framework-checkout-with-other-projects

GAME_CSPROJ="osu.Game/osu.Game.csproj"
ANDROID_PROPS="osu.Android.props"
IOS_PROPS="osu.iOS.props"
SLN="osu.sln"

dotnet remove $GAME_CSPROJ reference ppy.osu.Framework
dotnet remove $ANDROID_PROPS reference ppy.osu.Framework.Android
dotnet remove $IOS_PROPS reference ppy.osu.Framework.iOS

dotnet sln $SLN add ../ProjectYomi-framework/osu.Framework/osu.Framework.csproj \
    ../ProjectYomi-framework/osu.Framework.NativeLibs/osu.Framework.NativeLibs.csproj \
    ../ProjectYomi-framework/osu.Framework.Android/osu.Framework.Android.csproj \
    ../ProjectYomi-framework/osu.Framework.iOS/osu.Framework.iOS.csproj

dotnet add $GAME_CSPROJ reference ../ProjectYomi-framework/osu.Framework/osu.Framework.csproj
dotnet add $ANDROID_PROPS reference ../ProjectYomi-framework/osu.Framework.Android/osu.Framework.Android.csproj
dotnet add $IOS_PROPS reference ../ProjectYomi-framework/osu.Framework.iOS/osu.Framework.iOS.csproj

# workaround for dotnet add not inserting $(MSBuildThisFileDirectory) on props files
sed -i.bak 's:"..\\ProjectYomi-framework:"$(MSBuildThisFileDirectory)..\\ProjectYomi-framework:g' ./osu.Android.props && rm osu.Android.props.bak
sed -i.bak 's:"..\\ProjectYomi-framework:"$(MSBuildThisFileDirectory)..\\ProjectYomi-framework:g' ./osu.iOS.props && rm osu.iOS.props.bak

# needed because iOS framework nupkg includes a set of properties to work around certain issues during building,
# and those get ignored when referencing framework via project, threfore we have to manually include it via props reference.
sed -i.bak '/<\/Project>/i\
  <Import Project=\"$(MSBuildThisFileDirectory)../ProjectYomi-framework/osu.Framework.iOS.props\"/>\
' ./osu.iOS.props && rm osu.iOS.props.bak

tmp=$(mktemp)

jq '.solution.projects += ["../ProjectYomi-framework/osu.Framework/osu.Framework.csproj", "../ProjectYomi-framework/osu.Framework.NativeLibs/osu.Framework.NativeLibs.csproj"]' osu.Desktop.slnf > $tmp
mv -f $tmp osu.Desktop.slnf

jq '.solution.projects += ["../ProjectYomi-framework/osu.Framework/osu.Framework.csproj", "../ProjectYomi-framework/osu.Framework.NativeLibs/osu.Framework.NativeLibs.csproj", "../ProjectYomi-framework/osu.Framework.Android/osu.Framework.Android.csproj"]' osu.Android.slnf > $tmp
mv -f $tmp osu.Android.slnf

jq '.solution.projects += ["../ProjectYomi-framework/osu.Framework/osu.Framework.csproj", "../ProjectYomi-framework/osu.Framework.NativeLibs/osu.Framework.NativeLibs.csproj", "../ProjectYomi-framework/osu.Framework.iOS/osu.Framework.iOS.csproj"]' osu.iOS.slnf > $tmp
mv -f $tmp osu.iOS.slnf
