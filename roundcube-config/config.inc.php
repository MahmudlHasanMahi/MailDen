<?php
    $config['smtp_host'] = 'ssl://smtp.gmail.com:465';
    $config['smtp_user'] = getenv('ROUNDCUBEMAIL_SMTP_USER');
    $config['smtp_pass'] = getenv('ROUNDCUBEMAIL_SMTP_PASS');
    
    $config['smtp_auth_type'] = 'LOGIN';
    $config['smtp_conn_options'] = [
        'ssl' => [
            'verify_peer'       => false,
            'verify_peer_name'  => false,
            'allow_self_signed' => true,
        ],
    ];
    $config['plugins'] = [];
    $config['log_driver'] = 'stdout';
    $config['zipdownload_selection'] = true;
    $config['enable_spellcheck'] = true;
    $config['spellcheck_engine'] = 'pspell';
    
    include(__DIR__ . '/config.docker.inc.php');$config['des_key'] = 'zDs0TMpGgi0F2GN29dHn8jgm';
