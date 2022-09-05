{if $in_popup}
    <div class="adv-search">
    <div class="group">
{else}
    <div class="sidebar-row">
    <h6>{__("admin_search_title")}</h6>
{/if}

<form name="docs_search_form" action="{""|fn_url}" method="get" class="{$form_meta}">

    {if $smarty.request.redirect_url}
        <input type="hidden" name="redirect_url" value="{$smarty.request.redirect_url}" />
    {/if}

    {if $selected_section != ""}
        <input type="hidden" id="selected_section" name="selected_section" value="{$selected_section}" />
    {/if}

    {if $put_request_vars}
        {array_to_fields data=$smarty.request skip=["callback"]}
    {/if}

    {$extra nofilter}

    {capture name="simple_search"}
        <div class="sidebar-field">
            <label for="elm_name">{__("docs.docs")}</label>
            <div class="break">
                <input type="text" name="name" id="elm_name" value="{$search.name} {$search.description}" />
            </div>
        </div>

        <div class="sidebar-field">
            <label for="elm_category">{__("docs.document_category")}</label>
            <div class="controls">
                <select name="category" id="elm_category">
                    <option value="">{__("all")}</option>
                    <option {if $search.category == "O"}selected="selected"{/if} value="O">{__('docs.other')}</option>
                    <option {if $search.category == "A"}selected="selected"{/if} value="A">{__('docs.accounts')}</option>
                </select>
            </div>
        </div>

        <div class="sidebar-field">
            {include file="common/period_selector.tpl" period=$search.period extra="" display="form" button="false"}
        </div>
    {/capture}

    {include file="common/advanced_search.tpl" no_adv_link=true simple_search=$smarty.capture.simple_search dispatch=$dispatch view_type="docs"}

</form>

{if $in_popup}
    </div></div>
{else}
    </div><hr>
{/if}