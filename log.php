<?php

use PEAR2\Net\RouterOS;
use PEAR2\Net\RouterOS\Client;
use PEAR2\Net\RouterOS\Request;

// Fungsi untuk menampilkan log monitor
register_menu(" Log Mikrotik", true, "log_ui", 'AFTER_SETTINGS',  'ion-clipboard ', "New", "green");

function log_ui() {
    global $ui, $routes;
    _admin();
    $ui->assign('_title', 'Log Mikrotik');
    $ui->assign('_system_menu', 'Log Mikrotik');
    $admin = Admin::_info();
    $ui->assign('_admin', $admin);
    $routers = ORM::for_table('tbl_routers')->where('enabled', '1')->find_many();
    $routerId = $routes['2'] ?? ($routers ? $routers[0]['id'] : null); // Memastikan ada router yang aktif
    $logs = fetchLogs($routerId); // Mengambil log dari router yang dipilih
    $ui->assign('logs', $logs);

    $ui->display('log.tpl');
}

// Fungsi untuk mengambil logs dari MikroTik
function fetchLogs($routerId) {
    if (!$routerId) {
        return []; // Mengembalikan array kosong jika router tidak tersedia
    }
    
    $mikrotik = ORM::for_table('tbl_routers')->where('enabled', '1')->find_one($routerId);
    if (!$mikrotik) {
        return []; // Mengembalikan array kosong jika router tidak ditemukan
    }
    
    $client = Mikrotik::getClient($mikrotik['ip_address'], $mikrotik['username'], $mikrotik['password']);
    $request = new Request('/log/print');
    $response = $client->sendSync($request);
    
    $logs = [];
    foreach ($response as $entry) {
        $logs[] = $entry->getIterator()->getArrayCopy(); // Mengumpulkan data dari setiap entry
    }
    
    return $logs;
}