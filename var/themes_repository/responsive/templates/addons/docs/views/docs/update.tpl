{if $doc}
    {assign var="id" value=$doc.docs_id}
{else}
    {assign var="id" value=0}
{/if}


{$allow_save = $doc|fn_allow_save_object:"docs"}
{$hide_inputs = ""|fn_check_form_permissions}


<div class="container" style="margin-top:30px">
    <a href="{"docs.documents"|fn_url}" rel="nofollow" >{__("docs.return_to_docs")}</a>
    <br>
    <br>
    <div id="content_general">
        <div class="control-group">
            <span class="ty-control-group__title" size="20">{__("docs.docs_name")}</span>
            <span class="controls">{$doc.name}</span>
        </div>
    <hr>
        {if $doc.description}
        <div class="control-group" id="doc_text">
            <span class="ty-control-group__title" size="20">{__("docs.document_description")}</span>
            <span class="controls">{$doc.description}</span>
        </div>
    <hr>
        {/if}

        {if $doc.category}
        <div class="control-group">
            <span class="ty-control-group__title" size="20">{__("docs.document_category")}</span>
            <span class="controls">
                {if $doc.category == "O"}{__('docs.other')}{/if}
                {if $doc.category == "A"}{__('docs.accounts')}{/if}
            </span>
        </div>
    <hr>
        {/if}
        <span class="ty-control-group__title" size="20">{__('files')}</span>
        {if $attachments}
        <div class="control-group">

            
            <table width="100%" class="ty-table">
                <tbody>
                    {if $attachments}
                        {foreach from=$attachments item="file"}
                        <tr>
                            <td width='80%'>{$file.description}</td>
                            <td width='10%'>({$file.filesize|formatfilesize nofilter})
                            <td width='10%'><a class="ty-btn ty-btn__primary" href="{"docs.getfile?attachment_id=`$file.attachment_id`"|fn_url}">{__("download")}</a></td>
                        </tr>
                        {/foreach}
                    {/if}
                </tbody>
            </table>
        </div>
        {else}
            </br>
		    <p class="ty-no-items">{__("docs.no_files")}</p>
        {/if}

    </div>

</div>

