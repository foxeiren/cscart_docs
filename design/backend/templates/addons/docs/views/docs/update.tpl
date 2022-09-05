{if $doc}
    {assign var="docs_id" value=$doc.docs_id}
{else}
    {assign var="docs_id" value=0}
{/if}

{$allow_save = $doc|fn_allow_save_object:"docs"}
{$hide_inputs = ""|fn_check_form_permissions}

{capture name="mainbox"}

<form action="{""|fn_url}" method="post" class="form-horizontal form-edit{if !$allow_save || $hide_inputs} cm-hide-inputs{/if}" name="docs_form" enctype="multipart/form-data">
<input type="hidden" name="fake" value="1" />
<input type="hidden" name="docs_id" value="{$docs_id}" />
<input type="hidden" name="redirect_url" value="{$config.current_url}" />

{capture name="tabsbox"}

    <div id="content_general">
        <div class="control-group">
            <label for="elm_doc_name" class="control-label cm-required">{__("docs.docs_name")}</label>
            <div class="controls">
            <input type="text" name="doc_data[name]" id="elm_doc_name" value="{$doc.name}" size="25" class="input-large" /></div>
        </div>

        <div class="control-group">
            <label for="elm_doc_type" class="control-label cm-required">{__("docs.document_type")}</label>
            <div class="controls">
            <select name="doc_data[type]" id="elm_doc_type">
                <option {if $doc.type == "A"}selected="selected"{/if} value="A">{__('docs.for_all')}</option>
                <option {if $doc.type == "I"}selected="selected"{/if} value="I">{__('docs.interior')}</option>
            </select>
            </div>
        </div>

        <div class="control-group">
            <label for="elm_doc_category" class="control-label cm-required">{__("docs.document_category")}</label>
            <div class="controls">
            <select name="doc_data[category]" id="elm_doc_category">
                <option {if $doc.category == "O"}selected="selected"{/if} value="O">{__('docs.other')}</option>
                <option {if $doc.category == "A"}selected="selected"{/if} value="A">{__('docs.accounts')}</option>
            </select>
            </div>
        </div>

        <div class="control-group" id="doc_text">
            <label class="control-label" for="elm_doc_description">{__("docs.document_description")}:</label>
            <div class="controls">
                <textarea id="elm_doc_description" name="doc_data[description]" cols="35" rows="8" class="cm-wysiwyg input-large">{$doc.description}</textarea>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label" for="elm_doc_timestamp_{$id}">{__("docs.date_of_creation")}</label>
            <div class="controls">
            {include file="common/calendar.tpl" date_id="elm_doc_timestamp_`$id`" date_name="doc_data[timestamp]" date_val=$doc.timestamp|default:$smarty.const.TIME start_year=$settings.Company.company_start_year}
            </div>
        </div>

        {include file="views/localizations/components/select.tpl" data_name="doc_data[localization]" data_from=$doc.localization}

        {include file="common/select_status.tpl" input_name="doc_data[status]" id="elm_doc_status" obj_id=$id obj=$doc hidden=true}
        
    <!--content_general--></div>

    <div id="content_addons" class="hidden clearfix">

    <!--content_addons--></div>

    {* <div id="content_attachments" class="{if $selected_section !== "attachments"}hidden{/if}">
    <div class="btn-toolbar clearfix">
        <div class="pull-right">
            {capture name="add_new_picker"}
                {include file="addons/docs/views/docs/attachments_update.tpl" attachment=[] object_id=$docs_id object_type="docs"}
            {/capture}
            {include file="common/popupbox.tpl" id="add_new_attachments_files" text=__("new_attachment") link_text=__("add_attachment") content=$smarty.capture.add_new_picker act="general" icon="icon-plus"}
        </div>
    </div>

        {if $attachments}
        <div class="table-responsive-wrapper">
            <table class="table table-middle table--relative table-objects table-responsive table-responsive-w-titles">
            {foreach from=$attachments item="a"}
                {capture name="object_group"}
                {include file="addons/docs/views/docs/attachments_update.tpl" attachments=$a object_id=$object_id object_type=$object_type hide_inputs=$hide_inputs}
                {/capture}
                {include file="common/object_group.tpl"
                    content=$smarty.capture.object_group
                    id=$a.attachment_id
                    text=$a.description
                    status=$a.status
                    object_id_name="attachment_id"
                    table="attachments"
                    href_delete="attachments.delete?attachment_id=`$a.attachment_id`&object_id=`$object_id`&object_type=`$object_type`&redirect_url=`$redirect_url`"
                    delete_target_id="attachments_list"
                    header_text="{__("editing_attachment")}: `$a.description`" additional_class="cm-sortable-row cm-sortable-id-`$a.attachment_id`"
                    id_prefix="_attachments_"
                    prefix="attachments"
                    hide_for_vendor=$hide_for_vendor
                    skip_delete=$skip_delete
                    no_table="true"
                    link_text=$edit_link_text
                    draggable=true
                }
            {/foreach}
            </table>
        </div>
        {else}
            <p class="no-items">{__("no_data")}</p>
        {/if}
    </div> *}

{/capture}

{include file="common/tabsbox.tpl" content=$smarty.capture.tabsbox active_tab=$smarty.request.selected_section track=true}

{capture name="buttons"}
    {if !$docs_id}
        {include file="buttons/save_cancel.tpl" but_role="submit-link" but_target_form="docs_form" but_name="dispatch[docs.update]"}
    {else}
        {if "ULTIMATE"|fn_allowed_for && !$allow_save}
            {assign var="hide_first_button" value=true}
            {assign var="hide_second_button" value=true}
        {/if}
        {include file="buttons/save_cancel.tpl" but_name="dispatch[docs.update]" but_role="submit-link" but_target_form="docs_form" hide_first_button=$hide_first_button hide_second_button=$hide_second_button save=$docs_id}
    {/if}
{/capture}

</form>

{/capture}

{notes}
    {hook name="docs:update_notes"}
    {__("docs.details_notes", ["[layouts_href]" => fn_url('block_manager.manage')])}
    {/hook}
{/notes}

{include file="common/mainbox.tpl"
    title=($docs_id) ? $doc.name : __("docs.new_doc")
    content=$smarty.capture.mainbox
    buttons=$smarty.capture.buttons
    select_languages=true}

{** doc section **}
