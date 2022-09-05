<?php

use Tygh\BlockManager\Block;
use Tygh\Tools\SecurityHelper;
use Tygh\Enum\UserTypes;
use Tygh\Storage;

use Tygh\Registry;
use Tygh\Enum\YesNo;
use Tygh\Enum\ObjectStatuses;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

function fn_get_docs($params = array(), $lang_code = CART_LANGUAGE, $items_per_page = 0)
{

    $default_params = array(
        'page' => 1,
        'items_per_page' => $items_per_page
    );

    $params = array_merge($default_params, $params);

    if (AREA == 'C') {
        $params['status'] = 'A';
    }

    $sortings = array(
        'name' => '?:documents.name',
        'timestamp' => '?:documents.timestamp',
        'description' => '?:documents.description',
        'category' => '?:documents.category',
        'status' => '?:documents.status',
        'type' => '?:documents.type',
    );

    $condition = $limit = $join = '';

    if (!empty($params['limit'])) {
        $limit = db_quote(' LIMIT 0, ?i', $params['limit']);
    }

    $sorting = db_sort($params, $sortings, 'name', 'asc');

    $condition .= fn_get_localizations_condition('?:documents.localization');

    if (!empty($params['item_ids'])) {
        $condition .= db_quote(' AND ?:documents.docs_id IN (?n)', explode(',', $params['item_ids']));
    }

    if (!empty($params['name'])) {
        $condition .= db_quote(' AND ?:documents.name LIKE ?l', '%' . trim($params['name']) . '%');
    }

    if (!empty($params['type'])) {
        $condition .= db_quote(' AND ?:documents.type = ?s', $params['type']);
    }
    
    if (!empty($params['status'])) {
        $condition .= db_quote(' AND ?:documents.status = ?s', $params['status']);
    }
    
    if (!empty($params['period'])) {
        list($params['time_from'], $params['time_to']) = fn_create_periods($params);
        $condition .= db_quote(' AND (?:documents.timestamp >= ?i AND ?:documents.timestamp <= ?i)', $params['time_from'], $params['time_to']);
    }
    
    if (!empty($params['category'])) {
        $condition .= db_quote(' AND ?:documents.category = ?s', $params['category']);
    }

    // if (!empty($params['availability'])) {
    //     $condition .= db_quote(' AND ?:documents.availability = ?s', explode(',', $params['availability']));
    // }

    $fields = array (
        '?:documents.docs_id',
        '?:documents.name',
        '?:documents.status',
        '?:documents.type',
        '?:documents.timestamp',
        '?:documents.description',
        '?:documents.category',
        // '?:documents.availability',
    );

    /**
     * This hook allows you to change parameters of the doc selection before making an SQL query.
     *
     * @param array        $params    The parameters of the user's query (limit, period, item_ids, etc)
     * @param string       $condition The conditions of the selection
     * @param string       $sorting   Sorting (ask, desc)
     * @param string       $limit     The LIMIT of the returned rows
     * @param string       $lang_code Language code
     * @param array        $fields    Selected fields
     */
    fn_set_hook('get_docs', $params, $condition, $sorting, $limit, $lang_code, $fields);

    if (!empty($params['items_per_page'])) {
        $params['total_items'] = db_get_field("SELECT COUNT(*) FROM ?:documents $join WHERE 1 $condition");
        $limit = db_paginate($params['page'], $params['items_per_page'], $params['total_items']);
    }

    $docs = db_get_hash_array(
        "SELECT ?p FROM ?:documents " .
        $join .
        "WHERE 1 ?p ?p ?p",
        'docs_id', implode(', ', $fields), $condition, $sorting, $limit
    );

    if (!empty($params['item_ids'])) {
        $docs = fn_sort_by_ids($docs, explode(',', $params['item_ids']), 'docs_id');
    }

    // foreach ($docs as $docs_id => $doc) {
    // //     $docs[$docs_id]['main_pair'] = !empty($doc[$docs['docs_id']]) ? reset($doc[$docs['docs_id']]) : array();
    // // }

    fn_set_hook('get_docs_post', $docs, $params);

    return array($docs, $params);
}

function fn_get_doc_data($docs_id)
{
    // Unset all SQL variables
    $fields = $joins = array();
    $condition = '';

    $fields = array (
        '?:documents.docs_id',
        '?:documents.name',
        '?:documents.status',
        '?:documents.type',
        '?:documents.timestamp',
        '?:documents.description',
        '?:documents.category',
        // '?:documents.availability',
    );

    //  $joins[] = db_quote("LEFT JOIN ?:docs ON ?:docs_id = ?:docs_id");
    
     $condition = db_quote("WHERE ?:documents.docs_id = ?i", $docs_id);
    // $condition .= (AREA == 'A') ? '' : " AND ?:documents.status IN ('A', 'H') ";
    // $condition .= ($auth['user_type'] === UserTypes::ADMIN) ? '' : " AND ?:documents.type IN ('A') ";

    fn_set_hook('get_doc_data', $docs_id, $lang_code, $fields, $joins, $condition);

    $doc = db_get_row("SELECT " . implode(", ", $fields) . " FROM ?:documents " . implode(" ", $joins) ." $condition");

    fn_set_hook('get_doc_data_post', $docs_id, $lang_code, $doc);

    return $doc;
}

function fn_delete_doc_by_id($docs_id)
{
    if (!empty($docs_id)) {
        db_query("DELETE FROM ?:documents WHERE docs_id = ?i", $docs_id);

        fn_set_hook('delete_docs', $docs_id);

        Block::instance()->removeDynamicObjectData('docs', $docs_id);
    }
}

function fn_docs_update_doc($data, $docs_id)
{
    SecurityHelper::sanitizeObjectData('doc', $data);

    if (isset($data['timestamp'])) {
        $data['timestamp'] = fn_parse_date($data['timestamp']);
    }

    $data['localization'] = empty($data['localization']) ? '' : fn_implode_localizations($data['localization']);

    if (!empty($docs_id)) {
        db_query("UPDATE ?:documents SET ?u WHERE docs_id = ?i", $data, $docs_id);

    } else {
        $docs_id = $data['docs_id'] = db_query("REPLACE INTO ?:documents ?e", $data);

    }

    return $docs_id;
}




//file uploader

function fn_docs_get_files($doc_id, $lang_code)
{
    $attachments = db_get_array(
        "SELECT attachment_id, description, filename, filesize, status
        FROM ?:documents_attachments
        WHERE object_id = ?s AND lang_code = ?i", $doc_id, $lang_code);

    return $attachments;
}

function fn_docs_get_attachments($object_type, $object_id, $type = 'M', $lang_code = CART_LANGUAGE)
{
 
    fn_set_hook('get_attachments_pre', $object_type, $object_id, $type);

    $condition = '';
    if (AREA != 'A') {
        $auth = Tygh::$app['session']['auth'];
        $condition = db_quote(
            ' AND (?p) AND status = ?s',
            fn_find_array_in_set($auth['usergroup_ids'], 'usergroup_ids', true),
            ObjectStatuses::ACTIVE
        );
    }

        
    return db_get_array(
        'SELECT ?:documents_attachments.object_id, ?:documents.* FROM ?:documents '
        . 'LEFT JOIN ?:documents_attachments'
            . ' ON ?:documents.docs_id = ?:documents_attachments.object_id'
            . ' WHERE object_type = ?s AND object_id = ?i AND type = ?s ?p',
            $lang_code,
            $object_type,
            $object_id,
            $type,
            $condition
        );
}

function fn_update_docs_attachments(array $attachment_data, $attachment_id, $object_type, $object_id, $type = 'M', array $files = [], $lang_code = DESCR_SL)
{
    $uploaded_files = [];
    $object_id = intval($object_id);
    $directory = $object_type . '/' . $object_id;

    if (!empty($files)) {
        $uploaded_data = $files;
    } else {
        $uploaded_data = fn_filter_uploaded_data('attachment_files');
        $uploaded_data = reset($uploaded_data);
    }

    if (!empty($attachment_id)) {
        $data = [
            /** @var array{usergroup_ids: array<int>} $attachment_data */
            'usergroup_ids' => empty($attachment_data['usergroup_ids']) ? '0' : implode(',', $attachment_data['usergroup_ids']),
        ];

        db_query('UPDATE ?:documents_attachments SET description = ?s WHERE attachment_id = ?i AND lang_code = ?s', $attachment_data['description'], $attachment_id, $lang_code);
        db_query('UPDATE ?:documents_attachments SET ?u WHERE attachment_id = ?i AND object_type = ?s AND object_id = ?i AND type = ?s', $data, $attachment_id, $object_type, $object_id, $type);

        fn_set_hook('attachment_update_file', $attachment_data, $attachment_id, $object_type, $object_id, $type, $files, $uploaded_data);
    } elseif (!empty($uploaded_data)) {
        $attachment_data['type'] = $type;

        /** @var array{type: string, usergroup_ids: array<int>, position:int, description:string} $docs_data */
        $data = [
            'object_type'   => $object_type,
            'object_id'     => $object_id,
            'usergroup_ids' => empty($attachment_data['usergroup_ids']) ? '0' : implode(',', $attachment_data['usergroup_ids']),
            // 'position'      => $attachment_data['position']
        ];

        $data = array_merge($data, $attachment_data);

        $attachment_id = db_query('INSERT INTO ?:documents_attachments ?e', $data);

        fn_set_hook('attachment_add_file', $attachment_data, $object_type, $object_id, $type, $files, $attachment_id, $uploaded_data);
    }

    if ($attachment_id) {
        $uploaded_files[$attachment_id] = $uploaded_data;
    }

    if (
        empty($attachment_id)
        || empty($uploaded_files[$attachment_id])
        || empty($uploaded_files[$attachment_id]['size'])
    ) {
        return $attachment_id;
    }

    $old_filename = db_get_row('SELECT filename, on_server FROM ?:documents_attachments WHERE attachment_id = ?i', $attachment_id);

    if (YesNo::toBool($old_filename['on_server']) && !empty($old_filename['filename'])) {
        Storage::instance('attachments')->delete($directory . '/' . $old_filename['filename']);
    }

    $filename = $uploaded_files[$attachment_id]['name'];
    $filepath = $directory . '/' . $filename;

    if (empty($uploaded_files[$attachment_id]['url']) || YesNo::toBool(Registry::get('addons.docs.allow_save_documents_to_server'))) {
        list($filesize, $new_filename) = Storage::instance('attachments')->put($filepath, [
            'file' => $uploaded_files[$attachment_id]['path']
        ]);
    } else {
        $filesize = $uploaded_files[$attachment_id]['size'];
        $new_filename = $filename;
    }

    $update_data = [
        'filesize'  => $filesize,
        'on_server' => YesNo::YES,
        'filename'  => fn_basename($new_filename),
        'url'       => '',
    ];

    if (!empty($uploaded_files[$attachment_id]['url']) && !YesNo::toBool(Registry::get('addons.docs.allow_save_documents_to_server'))) {
        $update_data['on_server'] = YesNo::NO;
        $update_data['url'] = $uploaded_files[$attachment_id]['url'];
    }

    if (!empty($update_data['filesize'])) {
        db_query('UPDATE ?:documents_attachments SET ?u WHERE attachment_id = ?i', $update_data, $attachment_id);
    }

    return $attachment_id;
}

function fn_docs_delete_attachments($attachment_ids, $object_type, $object_id)
{
    fn_set_hook('attachments_delete_file', $attachment_ids, $object_type, $object_id);

    $data = db_get_array("SELECT * FROM ?:documents_attachments WHERE attachment_id IN (?n) AND object_type = ?s AND object_id = ?i", $attachment_ids, $object_type, $object_id);

    foreach ($data as $entry) {
        Storage::instance('attachments')->delete($entry['object_type'] . '/' . $object_id . '/' . $entry['filename']);
    }

    db_query("DELETE FROM ?:documents_attachments  WHERE attachment_id IN (?n) AND object_type = ?s AND object_id = ?i", $attachment_ids, $object_type, $object_id);
    db_query("DELETE FROM ?:documents_attachments  WHERE attachment_id IN (?n)", $attachment_ids);

    return true;
}

function fn_docs_get_attachment($attachment_id)
{
    $auth = Tygh::$app['session']['auth'];

    $condition = '';
    if (AREA != 'A') {
        $condition = ' AND (' . fn_find_array_in_set($auth['usergroup_ids'], 'usergroup_ids', true) . ") AND status = 'A'";
    }
    $data = db_get_row('SELECT * FROM ?:documents_attachments WHERE attachment_id = ?i ?p', $attachment_id, $condition);

    fn_set_hook('docs_get_attachment', $data, $attachment_id);

    if (empty($data)) {
        return false;
    }

    if (YesNo::toBool($data['on_server'])) {
        $documents_storage = Storage::instance('attachments');
        $attachment_filename = $data['object_type'] . '/' . $data['object_id'] . '/' . $data['filename'];

        if (!$documents_storage->isExist($attachment_filename)) {
            return false;
        }

        $documents_storage->get($attachment_filename);
        exit;
    }

    if (empty($data['url'])) {
        return false;
    }

    fn_redirect($data['url'], true);
    exit;
}
function fn_attachments_get_current_docs_by_url($object, $object_id, $url)
{
    return db_get_row(
        'SELECT * FROM ?:documents_attachments'
        . ' WHERE url = ?s AND object_id = ?i AND object_type = ?s',
        $url,
        $object_id,
        $object
    );
}