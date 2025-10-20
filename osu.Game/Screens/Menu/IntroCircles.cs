﻿// Copyright (c) ppy Pty Ltd <contact@ppy.sh>. Licensed under the MIT Licence.
// See the LICENCE file in the repository root for full licence text.

#nullable disable

using System;
using JetBrains.Annotations;
using osu.Framework.Allocation;
using osu.Framework.Audio;
using osu.Framework.Audio.Sample;
using osu.Framework.Graphics;
using osu.Framework.Screens;
using osu.Game.Audio;
using osu.Game.Skinning;

namespace osu.Game.Screens.Menu
{
    public partial class IntroCircles : IntroScreen
    {
        protected override string BeatmapHash => "3c8b1fcc9434dbb29e2fb613d3b9eada9d7bb6c125ceb32396c3b53437280c83";

        protected override string BeatmapFile => "circles.osz";

        public const double TRACK_START_DELAY = 600;

        private const double delay_for_menu = 2900;

        private SkinnableSound skinnableWelcome;
        private Sample welcome;

        public IntroCircles([CanBeNull] Func<MainMenu> createNextScreen = null)
            : base(createNextScreen)
        {
        }

        [BackgroundDependencyLoader]
        private void load(AudioManager audio)
        {
            if (MenuVoice.Value)
            {
                /*-
                if (api.LocalUser.Value.IsSupporter)
                    AddInternal(skinnableWelcome = new SkinnableSound(new SampleInfo(@"Intro/welcome")));
                else
                    welcome = audio.Samples.Get(@"Intro/welcome");
                */ //go clean up osu!supporter

                AddInternal(skinnableWelcome = new SkinnableSound(new SampleInfo(@"Intro/welcome")));
            }
        }

        protected override void LogoArriving(OsuLogo logo, bool resuming)
        {
            base.LogoArriving(logo, resuming);

            if (!resuming)
            {
                if (skinnableWelcome != null)
                    skinnableWelcome.Play();
                else
                    welcome?.Play();

                Scheduler.AddDelayed(delegate
                {
                    StartTrack();

                    PrepareMenuLoad();

                    Scheduler.AddDelayed(LoadMenu, delay_for_menu - TRACK_START_DELAY);
                }, TRACK_START_DELAY);

                logo.ScaleTo(1);
                logo.FadeIn();
                logo.PlayIntro();
            }
        }

        public override void OnSuspending(ScreenTransitionEvent e)
        {
            this.FadeOut(300);
            base.OnSuspending(e);
        }
    }
}
