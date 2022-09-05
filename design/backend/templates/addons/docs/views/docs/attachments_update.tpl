{$attachment = $a}

{if $attachment.attachment_id}
    {assign var="id" value=$attachment.attachment_id}    
{else}
    {assign var="id" value="0"}
{/if}

<form action="{""|fn_url}" method="post" class="form-horizontal form-edit  {$hide_inputs}" name="attachments_form_{$id}" enctype="multipart/form-data">
<input type="hidden" name="fake" value="1" />
<input type="hidden" name="object_id" value="{$object_id}" />
<input type="hidden" name="object_type" value="{$object_type}" />
<input type="hidden" name="attachment_id" value="{$id}" />
<input type="hidden" name="redirect_url" value="{$config.current_url}" />

<div class="cm-tabs-content">
    <div id="content_tab_details_{$id}">
        <div class="control-group">
            <label for="elm_description_{$id}" class="control-label cm-required">{__("name")}</label>
            <div class="controls">
                <input type="text" name="attachment_data[description]" id="elm_description_{$id}" size="60" class="input-medium" value="{$attachment.description}" />
            </div>
        </div>

        <div class="control-group">
            <label for="type_{"attachment_files[`$id`]"|md5}" class="control-label {if !$attachment}cm-required{/if}">{__("file")}</label>
            <div class="controls">
                {if $attachment.filename}
                    <div class="text-type-value">
                        <a href="{"attachments.getfile?attachment_id=`$attachment.attachment_id`&object_type=`$object_type`&object_id=`$object_id`"|fn_url}">{$attachment.filename}</a> ({$attachment.filesize|formatfilesize nofilter})
                    </div>
                {/if}
                {if !$hide_inputs}
                    {include file="common/fileuploader.tpl" var_name="attachment_files[`$id`]"}</div>
                {/if}
        </div>
    </div>
</div>

<div class="buttons-container">
    {if $id}
        {assign var="hide_first_button" value=$hide_inputs}
    {/if}

    {* {include file="buttons/save_cancel.tpl" but_name="dispatch[docs.update]" cancel_action="close" hide_first_button=$hide_first_button save=$id} *}
</div>

</form>