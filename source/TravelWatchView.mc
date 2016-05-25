using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Sensor as Sens;
using Toybox.ActivityMonitor as Act;
using Toybox.Attention as Att;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;
using Toybox.Application as App;


class TravelWatchView extends Ui.WatchFace {

    const CET_TIMEZONE_OFFSET = 7200;
    
    var font18LightAlpha, font18Light, font18Regular;
    var font44Light, font44Regular, font44Medium;
    var font72Light, font72Regular, font72Medium;
    var battery, steps, heart;
    var heartRate;


    function initialize() {
        WatchFace.initialize();
    }
 

    //! Load your resources here
    function onLayout(dc) {
        font18LightAlpha = Ui.loadResource(Rez.Fonts.roboto18LightAlpha);
        font18Light      = Ui.loadResource(Rez.Fonts.roboto18Light);
        font18Regular    = Ui.loadResource(Rez.Fonts.roboto18Regular);
        font44Light      = Ui.loadResource(Rez.Fonts.roboto44Light);
        font44Regular    = Ui.loadResource(Rez.Fonts.roboto44Regular);
        font44Medium     = Ui.loadResource(Rez.Fonts.roboto44Medium);
        font72Light      = Ui.loadResource(Rez.Fonts.roboto72Light);
        font72Regular    = Ui.loadResource(Rez.Fonts.roboto72Regular);
        font72Medium     = Ui.loadResource(Rez.Fonts.roboto72Medium);

        battery          = Ui.loadResource(Rez.Drawables.batteryIcon);
        steps            = Ui.loadResource(Rez.Drawables.stepsIcon);
        heart            = Ui.loadResource(Rez.Drawables.heartIcon);
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {        
        View.onUpdate(dc);
        
        var width              = dc.getWidth();
        var height             = dc.getHeight();
        var clockTime          = Sys.getClockTime();
        var nowinfo            = Greg.info(Time.now(), Time.FORMAT_SHORT);
        var actinfo            = Act.getInfo();
        var systemStats        = Sys.getSystemStats();
        var hrIter             = Act.getHeartRateHistory(null, true);
        var hr                 = hrIter.next();
        var hourString         = Lang.format(clockTime.hour.format("%02d"));
        var minuteString       = Lang.format(clockTime.min.format("%02d"));
        var homeTimezoneOffset = App.getApp().getProperty("HomeTimezoneOffset");
        var onTravel           = homeTimezoneOffset != clockTime.timeZoneOffset;        
        var stepsString        = actinfo.steps.toString();
        var kcalString         = actinfo.calories.toString() + " kcal";        
        var dateString         = Lang.format(nowinfo.day.format("%02d")) + "." + Lang.format(nowinfo.month.format("%02d"));
        var bpmString          = (hr.heartRate != Act.INVALID_HR_SAMPLE && hr.heartRate > 0) ? hr.heartRate : "";
        var charge             = systemStats.battery;


        // Battery
        dc.drawBitmap(96, 3, battery);
        dc.setColor(charge < 20 ? Gfx.COLOR_RED : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(98, 5 , 20.0 * charge / 100, 7);
        
        // Date
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        if (onTravel) {
            dc.drawText(20, height * 0.11, font18Light, dateString, Gfx.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(width * 0.5, height * 0.11, font18Light, dateString, Gfx.TEXT_JUSTIFY_CENTER);
        }

        // Home Time
        if (onTravel) {
            var currentSeconds = clockTime.hour * 3600 + clockTime.min * 60 + clockTime.sec;
            var utcSeconds     = currentSeconds - clockTime.timeZoneOffset;
            var homeSeconds    = utcSeconds - homeTimezoneOffset;
            var homeHour       = ((homeSeconds / 3600)).toNumber() % 24l;
            var homeMinute     = ((homeSeconds - (homeHour.abs() * 3600)) / 60) % 60;
                        
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(150, height * 0.11, font18Light, Lang.format(homeHour.abs().format("%02d")), Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(App.getApp().getProperty("HomeMinuteColor"), Gfx.COLOR_TRANSPARENT);
            dc.drawText(176, height * 0.11, font18Light, Lang.format(homeMinute.abs().format("%02d")), Gfx.TEXT_JUSTIFY_CENTER);
        }
        
        // Current Time
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(65, height * 0.2, font72Medium, hourString, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(App.getApp().getProperty("CurrentMinuteColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(157, height * 0.2, font72Light, minuteString, Gfx.TEXT_JUSTIFY_CENTER);

        // KCal
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(20, 127, font18LightAlpha, kcalString, Gfx.TEXT_JUSTIFY_LEFT);        

        // BPM
        dc.drawBitmap(139, 134, heart);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(165, 127, font18Light, bpmString, Gfx.TEXT_JUSTIFY_LEFT);
        
        // Steps
        dc.drawBitmap(69, 161, steps);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(93, 156, font18Light, stepsString, Gfx.TEXT_JUSTIFY_LEFT);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}