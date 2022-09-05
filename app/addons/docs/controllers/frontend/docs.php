<?php

use Tygh\Registry;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    return;
}

if ($mode == 'getfile') {
    if (!empty($_REQUEST['attachment_id'])) {

        if (fn_docs_get_attachment($_REQUEST['attachment_id']) === false) {
            return [CONTROLLER_STATUS_NO_PAGE];
        }
    }
    exit;
}

if ($mode == 'documents') {

    list($docs, $params) = fn_get_docs($_REQUEST, DESCR_SL, Registry::get('settings.Appearance.admin_elements_per_page'));

    Tygh::$app['view']->assign(array(
        'docs'  => $docs,
        'search' => $params,
    ));
    
} 

if ($mode == 'update') {
    $doc = fn_get_doc_data($_REQUEST['docs_id'], DESCR_SL);
    $attachments = fn_docs_get_files($_REQUEST['docs_id'], CART_LANGUAGE);

    if (empty($doc)) {
        return array(CONTROLLER_STATUS_NO_PAGE);
    }
    Tygh::$app['view']->assign('doc', $doc);
    Tygh::$app['view']->assign('attachments', $attachments);

}

$auth = &Tygh::$app['session']['auth'];

if($mode == 'search'){

    fn_add_breadcrumb(__('invoices'));

    if(empty($auth['user_id'])){
        return [CONTROLLER_STATUS_REDIRECT, ""];
    }

    $statuses =  fn_get_statuses();

    $_statuses = [];
    foreach ($statuses as $status){
        if(empty($status['params']['disable_invoice_printing']) || (!empty($status['params']['disable_invoice_printing']) && $status['params']['disable_invoice_printing'] == YesNo::NO)){
            $_statuses[] = $status['status'];
        }
    }

    $params = [
        'user_id' => $auth['user_id'],
        'items_per_page' => 10,
        'status' => $_statuses,
    ];

    $params = array_merge($params, $_REQUEST);

    list($docs, $search) = fn_get_docs($docs);

    Tygh::$app['view']->assign('docs', $docs);
    Tygh::$app['view']->assign('search', $search);

}



