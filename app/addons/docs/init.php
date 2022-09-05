<?php



use Tygh\Registry;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

// fn_register_hooks(
//     'clone_product',
//     'delete_product_post',
//     'init_product_tabs_post'
// );

Registry::set('config.storage.documents', array(
    'prefix' => 'documents',
    'secured' => true,
    'dir' => Registry::get('config.dir.var')
));
