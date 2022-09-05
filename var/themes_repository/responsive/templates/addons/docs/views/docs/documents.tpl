{$c_url = $config.current_url|fn_query_remove:"sort_by":"sort_order"}
{if $search.sort_order == "asc"}
    {include_ext file="common/icon.tpl" class="ty-icon-down-dir" assign=sort_sign}
{else}
    {include_ext file="common/icon.tpl" class="ty-icon-up-dir" assign=sort_sign}
{/if}
{if !$config.tweaks.disable_dhtml}
    {$ajax_class = "cm-ajax"}
{/if}

<form action="{""|fn_url}" class="ty-docs-search-options" name="docs_search_form" method="get">

<div class="clearfix">

    <div class="span4 ty-control-group">
        <label class="ty-control-group__title">{__("docs.docs")}&nbsp;</label>
        <input type="text" name="name" value="{$docs.name}" size="20" class="docs.name" />
    </div>
    <div class="span12 ty-control-group">
        {include file="common/period_selector.tpl" period=$docs.period form_name="date_of_creation"}
    </div>
</div>

<hr>

<div class="buttons-container ty-search-form__buttons-container">
    {include file="buttons/button.tpl" but_meta="ty-btn__secondary" but_text=__("storefront_search_button") but_name="dispatch[docs.documents]"}
</div>
</form>

{include file="common/pagination.tpl"}

<div id="threads_container">
    <table class="ty-table ty-vendor-communication-search" id="threads_table">
        <thead>
        <tr>
            <th width="3%" class="ty-vendor-communication-search__label hidden-phone">&nbsp;</th>
            {if $show_subject_image_column}
                <th width="7%">&nbsp;</th>
            {/if}
            <th><a class="cm-ajax" href="{"`$c_url`&sort_by=name&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.docs_name")}{if $search.sort_by === "name"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="15%"><a class="cm-ajax" href="{"`$c_url`&sort_by=timestamp&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.date_of_creation")}{if $search.sort_by === "timestamp"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="10%" class="mobile-hide"><a class="cm-ajax" href="{"`$c_url`&sort_by=type&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.document_category")}{if $search.sort_by === "category"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                

            {hook name="docs:manage_header"}{/hook}
        </tr>
        </thead>
        {foreach from=$docs item=doc}
            <tr>
                <td width="6%" class="left mobile-hide">
                    <input type="checkbox" name="docs_ids[]" value="{$doc.docs_id}" class="cm-item {$no_hide_input} cm-item-status-{$doc.status|lower} hide" /></td>
                <td class="{$no_hide_input}" data-th="{__("docs.docs")}">
                    <a class="row-status" href="{"docs.update?docs_id=`$doc.docs_id`"|fn_url}">{$doc.name}</a>
                </td>
                <td width="15%" data-th="{__("creation_date")}">
                    {$doc.timestamp|date_format:"`$settings.Appearance.date_format`, `$settings.Appearance.time_format`"}
                </td>
                <td width="15%" data-th="{__("category")}">
                    {if $doc.category == "O"}{__('docs.other')}{else}{__('docs.accounts')}{/if}
                </td>
               
            </tr>
        {/foreach}
        <!--threads_table--></table>

    {include file="common/pagination.tpl"}


<!--threads_container--></div>

{capture name="mainbox_title"}{__("docs.docs")}{/capture}



