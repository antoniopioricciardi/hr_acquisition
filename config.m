function cfg = config()
    % demo parameters
    cfg.num_demo_sessions = 2;
    cfg.tests_per_delay   = 2;

    % peak parameters
    cfg.peak_delay_synch  = 0.2;
    cfg.peak_delay_asynch = 0.8;
    cfg.max_peaks         = 10;

    % audio files
    cfg.gong_file         = 'gong.mat';

    % streaming
    cfg.fs_stream         = 1000;
    cfg.n_seconds_valid   = 10;

    % psychtoolbox
    cfg.skipSyncTests     = true;

    cfg.sound_pitch = 200;
end