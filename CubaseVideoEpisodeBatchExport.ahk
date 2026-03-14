#Requires AutoHotkey v2.0
#SingleInstance Force

global NextEventShortcut := '{Right}'
global LocatorsToSelectionShortcut := 'p'
global MenuDelayMs := 350
global ExportDialogDelayMs := 1200
global AfterClickDelayMs := 500
global ExportWaitMs := 3000
global gExportWaitSeconds := 3
global gStableCheckSeconds := 2
global CalFile := A_ScriptDir '\batch_export_video_calibration.ini'
global LogFile := A_ScriptDir '\batch_export_debug.log'

global gFileNameX := 0
global gFileNameY := 0
global gReplaceX := 0
global gReplaceY := 0
global gUseFileNameField := false

global gFileMenuX := 0
global gFileMenuY := 0
global gExportMenuX := 0
global gExportMenuY := 0
global gVideoMenuX := 0
global gVideoMenuY := 0

global gBatchRunning := false
global CubaseWinTitle := 'ahk_exe Cubase13.exe'

global gRenameEnabled := false
global gRenameDramaName := ''
global gRenameLanguage := ''
global gRenameOutputDir := ''
global gTempTokenPrefix := '__codex_tmp_ep_'

SetKeyDelay(80, 80)
LoadCalibration()

^!+h::ShowHelp()
^!+1::CapturePoint('FileName')
^!+2::CapturePoint('ReplaceButton')
^!+3::CapturePoint('FileMenu')
^!+4::CapturePoint('ExportMenu')
^!+5::CapturePoint('VideoMenu')
^!+b::StartBatch()
^!+s::StopBatch()
^!+t::TestOneStep()

ShowHelp() {
    text := "
    (
Cubase 分集视频批量导出助手

这版脚本不再依赖导出视频快捷键，而是直接点击：
文件 -> 导出 -> 视频

热键:
Ctrl+Alt+Shift+1  记录“添加到视频文件名”输入框位置
Ctrl+Alt+Shift+2  记录 Replace Audio 按钮位置
Ctrl+Alt+Shift+3  记录“文件”菜单位置
Ctrl+Alt+Shift+4  记录“导出”菜单位置
Ctrl+Alt+Shift+5  记录“视频”菜单位置
Ctrl+Alt+Shift+T  测试当前这一集的单步导出动作
Ctrl+Alt+Shift+B  开始批量导出
Ctrl+Alt+Shift+S  停止批量导出
    )"
    MsgBox(text, 'Cubase Episodic Video Export')
}

Log(msg) {
    global LogFile
    FileAppend(FormatTime(, 'yyyy-MM-dd HH:mm:ss') ' | ' msg '`n', LogFile, 'UTF-8')
}

WaitForTriggerKeysRelease() {
    KeyWait('Ctrl')
    KeyWait('Alt')
    KeyWait('Shift')
    Sleep(120)
}

CapturePoint(kind) {
    global CalFile, gUseFileNameField
    global gFileNameX, gFileNameY, gReplaceX, gReplaceY
    global gFileMenuX, gFileMenuY, gExportMenuX, gExportMenuY, gVideoMenuX, gVideoMenuY
    MouseGetPos(&x, &y)
    switch kind {
        case 'FileName':
            gFileNameX := x, gFileNameY := y, gUseFileNameField := true
            IniWrite(x, CalFile, 'Points', 'FileNameX')
            IniWrite(y, CalFile, 'Points', 'FileNameY')
            IniWrite(1, CalFile, 'Points', 'UseFileNameField')
            MsgBox('已记录文件名输入框位置: ' x ',' y)
        case 'ReplaceButton':
            gReplaceX := x, gReplaceY := y
            IniWrite(x, CalFile, 'Points', 'ReplaceX')
            IniWrite(y, CalFile, 'Points', 'ReplaceY')
            MsgBox('已记录 Replace Audio 按钮位置: ' x ',' y)
        case 'FileMenu':
            gFileMenuX := x, gFileMenuY := y
            IniWrite(x, CalFile, 'Points', 'FileMenuX')
            IniWrite(y, CalFile, 'Points', 'FileMenuY')
            MsgBox('已记录“文件”菜单位置: ' x ',' y)
        case 'ExportMenu':
            gExportMenuX := x, gExportMenuY := y
            IniWrite(x, CalFile, 'Points', 'ExportMenuX')
            IniWrite(y, CalFile, 'Points', 'ExportMenuY')
            MsgBox('已记录“导出”菜单位置: ' x ',' y)
        case 'VideoMenu':
            gVideoMenuX := x, gVideoMenuY := y
            IniWrite(x, CalFile, 'Points', 'VideoMenuX')
            IniWrite(y, CalFile, 'Points', 'VideoMenuY')
            MsgBox('已记录“视频”菜单位置: ' x ',' y)
    }
}

LoadCalibration() {
    global CalFile, gUseFileNameField
    global gFileNameX, gFileNameY, gReplaceX, gReplaceY
    global gFileMenuX, gFileMenuY, gExportMenuX, gExportMenuY, gVideoMenuX, gVideoMenuY
    if !FileExist(CalFile)
        return
    gFileNameX := Integer(IniRead(CalFile, 'Points', 'FileNameX', '0'))
    gFileNameY := Integer(IniRead(CalFile, 'Points', 'FileNameY', '0'))
    gReplaceX := Integer(IniRead(CalFile, 'Points', 'ReplaceX', '0'))
    gReplaceY := Integer(IniRead(CalFile, 'Points', 'ReplaceY', '0'))
    gFileMenuX := Integer(IniRead(CalFile, 'Points', 'FileMenuX', '0'))
    gFileMenuY := Integer(IniRead(CalFile, 'Points', 'FileMenuY', '0'))
    gExportMenuX := Integer(IniRead(CalFile, 'Points', 'ExportMenuX', '0'))
    gExportMenuY := Integer(IniRead(CalFile, 'Points', 'ExportMenuY', '0'))
    gVideoMenuX := Integer(IniRead(CalFile, 'Points', 'VideoMenuX', '0'))
    gVideoMenuY := Integer(IniRead(CalFile, 'Points', 'VideoMenuY', '0'))
    gUseFileNameField := (IniRead(CalFile, 'Points', 'UseFileNameField', '0') = '1')
}

ActivateCubase() {
    global CubaseWinTitle
    if !WinExist(CubaseWinTitle) {
        MsgBox('没有检测到 Cubase13.exe。')
        return false
    }
    WinActivate(CubaseWinTitle)
    Sleep(250)
    return true
}

SendProjectHotkey(keys, stepName) {
    if !ActivateCubase()
        return false
    ; Do not click into the project area here, because that can cancel the currently selected video event.
    Log('Send step=' stepName ' keys=' keys)
    SendInput(keys)
    Sleep(220)
    return true
}

OpenExportVideoDialog() {
    global gFileMenuX, gFileMenuY, gExportMenuX, gExportMenuY, gVideoMenuX, gVideoMenuY, MenuDelayMs
    if (gFileMenuX = 0 or gExportMenuX = 0 or gVideoMenuX = 0) {
        MsgBox('请先记录“文件/导出/视频”三个菜单位置。')
        return false
    }
    if !ActivateCubase()
        return false
    Log('Open export dialog by menu clicks')

    ; First move explicitly to each calibrated menu point so the first click does not drift.
    MouseMove(gFileMenuX, gFileMenuY, 0)
    Sleep(80)
    MouseClick('Left', gFileMenuX, gFileMenuY)
    Sleep(MenuDelayMs)

    MouseMove(gExportMenuX, gExportMenuY, 0)
    Sleep(80)
    MouseClick('Left', gExportMenuX, gExportMenuY)
    Sleep(MenuDelayMs)

    MouseMove(gVideoMenuX, gVideoMenuY, 0)
    Sleep(80)
    MouseClick('Left', gVideoMenuX, gVideoMenuY)
    Sleep(MenuDelayMs)
    return true
}

TestOneStep() {
    WaitForTriggerKeysRelease()
    ok := ExportCurrentEvent(0, true)
    if !ok
        MsgBox('单步测试失败，请把 D:\codex\cubase-batch-export\batch_export_debug.log 发给我。')
}

AskExportWaitSeconds() {
    global gExportWaitSeconds, ExportWaitMs
    result := InputBox('请输入导出后的基础等待秒数。默认 3；脚本还会额外等待文件稳定后再重命名。', '导出等待时间', , '3')
    if (result.Result != 'OK')
        return false
    secs := Integer(result.Value)
    if (secs < 1)
        secs := 3
    gExportWaitSeconds := secs
    ExportWaitMs := secs * 1000
    Log('Export wait seconds=' gExportWaitSeconds)
    return true
}

AskRenameSettings() {
    global gRenameEnabled, gRenameDramaName, gRenameLanguage, gRenameOutputDir, gUseFileNameField
    gRenameEnabled := false, gRenameDramaName := '', gRenameLanguage := '', gRenameOutputDir := ''
    enableResult := MsgBox('这次批量导出后，是否自动重命名为“短剧名-语种-第X集”？', '自动重命名', 'YesNo Icon?')
    if (enableResult != 'Yes') {
        Log('Rename disabled for this batch')
        return true
    }
    if !gUseFileNameField {
        MsgBox('自动重命名需要先记录“添加到视频文件名”输入框位置。')
        return false
    }
    dramaResult := InputBox('请输入短剧名，例如：最后的礼物', '自动重命名')
    if (dramaResult.Result != 'OK')
        return false
    langResult := InputBox('请输入语种，例如：印尼语', '自动重命名')
    if (langResult.Result != 'OK')
        return false
    pickedDir := DirSelect('*', 0, '请选择本次导出视频所在文件夹')
    if (pickedDir = '')
        return false
    gRenameDramaName := SanitizeFileName(Trim(dramaResult.Value))
    gRenameLanguage := SanitizeFileName(Trim(langResult.Value))
    gRenameOutputDir := pickedDir
    gRenameEnabled := true
    return true
}

StartBatch() {
    global gBatchRunning, gReplaceX, gReplaceY, LogFile
    WaitForTriggerKeysRelease()
    FileDelete(LogFile)
    Log('Batch start')
    if (gReplaceX = 0 or gReplaceY = 0) {
        MsgBox('请先记录 Replace Audio 按钮位置。')
        return
    }
    if !AskExportWaitSeconds()
        return
    if !AskRenameSettings()
        return
    result := InputBox('请输入这次要连续导出的集数，例如 2', '批量导出')
    if (result.Result != 'OK')
        return
    total := Integer(result.Value)
    if (total <= 0) {
        MsgBox('集数必须大于 0。')
        return
    }
    startResult := InputBox('请输入起始集号，例如 26', '批量导出')
    if (startResult.Result != 'OK')
        return
    startEpisode := Integer(startResult.Value)
    gBatchRunning := true
    Loop total {
        currentEpisode := startEpisode + A_Index - 1
        Log('Begin episode ' currentEpisode)
        if !ExportCurrentEvent(currentEpisode, false) {
            gBatchRunning := false
            MsgBox('批量导出在第 ' currentEpisode ' 集停止。请查看日志：D:\codex\cubase-batch-export\batch_export_debug.log')
            return
        }
        if (A_Index < total) {
            Sleep(600)
            SendProjectHotkey(NextEventShortcut, 'next_event')
            Sleep(600)
        }
    }
    gBatchRunning := false
    MsgBox('批量导出流程已执行完毕。')
}

StopBatch() {
    WaitForTriggerKeysRelease()
    global gBatchRunning
    gBatchRunning := false
}

ExportCurrentEvent(epNo, testMode := false) {
    global LocatorsToSelectionShortcut, ExportDialogDelayMs, AfterClickDelayMs, ExportWaitMs
    global gUseFileNameField, gFileNameX, gFileNameY, gReplaceX, gReplaceY
    global gRenameEnabled, gRenameOutputDir, gTempTokenPrefix
    tempToken := ''
    beforeState := Map()
    if (gRenameEnabled and epNo > 0) {
        tempToken := gTempTokenPrefix . Format('{:03}', epNo)
        beforeState := CaptureDirectoryState(gRenameOutputDir)
    }
    if !SendProjectHotkey(LocatorsToSelectionShortcut, 'locators_to_selection')
        return false
    Sleep(250)
    if !OpenExportVideoDialog()
        return false
    Sleep(ExportDialogDelayMs)
    if (gRenameEnabled and gUseFileNameField and gFileNameX > 0 and gFileNameY > 0 and epNo > 0) {
        MouseClick('Left', gFileNameX, gFileNameY)
        Sleep(AfterClickDelayMs)
        SendInput('^a')
        Sleep(100)
        SendText(tempToken)
        Sleep(180)
    }
    Log('Click Replace Audio at ' gReplaceX ',' gReplaceY)
    MouseClick('Left', gReplaceX, gReplaceY)
    Sleep(ExportWaitMs)
    if (gRenameEnabled and epNo > 0) {
        exportedFile := WaitForExportedFile(gRenameOutputDir, beforeState, tempToken, 30)
        if (exportedFile = '') {
            MsgBox('第 ' epNo ' 集导出后，没有在目标文件夹找到新文件或刚更新的视频文件。')
            return false
        }
        finalPath := BuildFinalOutputPath(exportedFile, epNo)
        try FileMove(exportedFile, finalPath)
        catch as err {
            MsgBox('第 ' epNo ' 集自动重命名失败。`n错误: ' err.Message)
            return false
        }
    }
    if (testMode)
        MsgBox('单步测试动作已执行。')
    return true
}

CaptureDirectoryState(dirPath) {
    state := Map()
    Loop Files, dirPath '\*.*', 'F' {
        extLower := StrLower(A_LoopFileExt)
        if (extLower != 'mp4' and extLower != 'mov' and extLower != 'mkv')
            continue
        state[A_LoopFileFullPath] := FileGetTime(A_LoopFileFullPath, 'M') '|' FileGetSize(A_LoopFileFullPath)
    }
    return state
}

WaitForExportedFile(dirPath, beforeState, token, timeoutSeconds := 120) {
    deadline := A_TickCount + timeoutSeconds * 1000
    Loop {
        found := FindChangedOrTaggedFile(dirPath, beforeState, token)
        if (found != '')
            return found
        if (A_TickCount >= deadline)
            return ''
        Sleep(500)
    }
}

FindChangedOrTaggedFile(dirPath, beforeState, token) {
    latestPath := '', latestTime := ''
    Loop Files, dirPath '\*.*', 'F' {
        extLower := StrLower(A_LoopFileExt)
        if (extLower != 'mp4' and extLower != 'mov' and extLower != 'mkv')
            continue
        currentSig := FileGetTime(A_LoopFileFullPath, 'M') '|' FileGetSize(A_LoopFileFullPath)
        isNewOrChanged := !beforeState.Has(A_LoopFileFullPath) || (beforeState[A_LoopFileFullPath] != currentSig)
        hasToken := InStr(StrLower(A_LoopFileName), StrLower(token))
        if !(isNewOrChanged || hasToken)
            continue
        modified := FileGetTime(A_LoopFileFullPath, 'M')
        if (latestTime = '' or modified > latestTime)
            latestTime := modified, latestPath := A_LoopFileFullPath
    }
    return latestPath
}

BuildFinalOutputPath(sourceFile, epNo) {
    global gRenameDramaName, gRenameLanguage, gRenameOutputDir
    SplitPath(sourceFile, , , &ext)
    safeBase := SanitizeFileName(gRenameDramaName '-' gRenameLanguage '-第' epNo '集')
    candidate := gRenameOutputDir '\' safeBase '.' ext
    if !FileExist(candidate)
        return candidate
    suffix := 2
    Loop {
        numbered := gRenameOutputDir '\' safeBase '_' suffix '.' ext
        if !FileExist(numbered)
            return numbered
        suffix += 1
    }
}

SanitizeFileName(name) {
    cleaned := name
    for bad in ['\', '/', ':', '*', '?', '"', '<', '>', '|']
        cleaned := StrReplace(cleaned, bad, '-')
    cleaned := Trim(cleaned)
    while InStr(cleaned, '--')
        cleaned := StrReplace(cleaned, '--', '-')
    return cleaned
}



TryRenameWithRetry(sourceFile, targetFile, maxAttempts := 20, delayMs := 500) {
    attempt := 1
    Loop maxAttempts {
        try {
            FileMove(sourceFile, targetFile)
            return true
        } catch as err {
            Log('Rename attempt ' attempt ' failed: ' err.Message)
            if (attempt >= maxAttempts)
                return false
            Sleep(delayMs)
            attempt += 1
        }
    }
    return false
}


WaitForFileStable(filePath, timeoutSeconds := 120, stableSeconds := 2) {
    if !FileExist(filePath)
        return false
    deadline := A_TickCount + timeoutSeconds * 1000
    stableNeedMs := stableSeconds * 1000
    lastSig := ''
    stableStart := 0
    Loop {
        if !FileExist(filePath)
            return false
        currentSig := FileGetTime(filePath, 'M') '|' FileGetSize(filePath)
        if (currentSig != lastSig) {
            lastSig := currentSig
            stableStart := A_TickCount
            Log('File still changing: ' filePath ' sig=' currentSig)
        } else {
            if ((A_TickCount - stableStart) >= stableNeedMs) {
                Log('File stable: ' filePath)
                return true
            }
        }
        if (A_TickCount >= deadline) {
            Log('File stability wait timeout: ' filePath)
            return false
        }
        Sleep(500)
    }
}
