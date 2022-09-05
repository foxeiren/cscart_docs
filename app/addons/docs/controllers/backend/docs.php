<?php

use Tygh\Registry;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

if ($_SERVER['REQUEST_METHOD']	== 'POST') {

    fn_trusted_vars('doc', 'doc_data');
    $suffix = '';

    if ($mode == 'update') {
        $doc_id = fn_docs_update_doc($_REQUEST['doc_data'], $_REQUEST['docs_id'], DESCR_SL);

        $suffix = ".update?docs_id=$doc_id";

        if (!empty($_REQUEST['attachment_data'])) {
            fn_update_docs_attachments(
                $_REQUEST['attachment_data'],
                $_REQUEST['attachment_id'],
                $_REQUEST['object_type'],
                $_REQUEST['object_id'],
                'M',
                [],
                DESCR_SL
            );
        }
    }

    if ($mode == 'delete') {
        if (!empty($_REQUEST['docs_id'])) {
            fn_delete_doc_by_id($_REQUEST['docs_id']);
        }

        $suffix = '.manage';

        fn_docs_delete_attachments(array($_REQUEST['attachment_id']), $_REQUEST['object_type'], $_REQUEST['object_id']);
        $attachments = fn_docs_get_attachments($_REQUEST['object_type'], $_REQUEST['object_id']);
        if (empty($attachments)) {
            Tygh::$app['view']->assign('object_type', $_REQUEST['object_type']);
            Tygh::$app['view']->assign('object_id', $_REQUEST['object_id']);
            Tygh::$app['view']->display('addons/docs/views/docs/manage.tpl');
        }
        exit;
    }
    return array(CONTROLLER_STATUS_OK, 'docs' . $suffix);

    // return array(CONTROLLER_STATUS_OK); // redirect should be performed via redirect_url always
}

if ($mode == 'getfile') {
    if (!empty($_REQUEST['attachment_id'])) {
        fn_docs_get_attachment($_REQUEST['attachment_id']);
    }
    exit;

} elseif ($mode == 'update') {
    $doc = fn_get_doc_data($_REQUEST['docs_id'], DESCR_SL);
    
    if (empty($doc)) {
        return array(CONTROLLER_STATUS_NO_PAGE);
    }

    Registry::set('navigation.tabs', array (
        'general' => array (
            'title' => __('general'),
            'js' => true
        ),
    ));

    Registry::set('navigation.tabs.attachments', array (
        'title' => __('attachments'),
        'js' => true
    ));

    Tygh::$app['view']->assign('doc', $doc);

    $attachments = fn_docs_get_files($_REQUEST['docs_id'], CART_LANGUAGE);

    Tygh::$app['view']->assign('attachments', $attachments);

    
} elseif ($mode == 'manage') {
    
    list($docs, $params) = fn_get_docs($_REQUEST, DESCR_SL, Registry::get('settings.Appearance.admin_elements_per_page'));
    
    Tygh::$app['view']->assign(array(
        'docs'  => $docs,
        'search' => $params,
    ));

}