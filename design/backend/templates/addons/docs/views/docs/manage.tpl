

{capture name="mainbox"}

<form action="{""|fn_url}" method="post" id="docs_form" name="docs_form" enctype="multipart/form-data">
<input type="hidden" name="fake" value="1" />
{include file="common/pagination.tpl" save_current_page=true save_current_url=true div_id="pagination_contents_docs"}

{$c_url=$config.current_url|fn_query_remove:"sort_by":"sort_order"}

{$rev=$smarty.request.content_id|default:"pagination_contents_docs"}
{include_ext file="common/icon.tpl" class="icon-`$search.sort_order_rev`" assign=c_icon}
{include_ext file="common/icon.tpl" class="icon-dummy" assign=c_dummy}
{$docs_statuses=""|fn_get_default_statuses:true}
{$has_permission = fn_check_permissions("docs", "update_status", "admin", "POST")}

{if $docs}
    {capture name="docs_table"}
        <div class="table-responsive-wrapper longtap-selection">
            <table class="table table-middle table--relative table-responsive">
            <thead
                data-ca-bulkedit-default-object="true"
                data-ca-bulkedit-component="defaultObject"
            >
            <tr>
                <th width="6%" class="left mobile-hide">
                    {include file="common/check_items.tpl" is_check_disabled=!$has_permission check_statuses=($has_permission) ? $docs_statuses : '' }

                    <input type="checkbox"
                        class="bulkedit-toggler hide"
                        data-ca-bulkedit-disable="[data-ca-bulkedit-default-object=true]"
                        data-ca-bulkedit-enable="[data-ca-bulkedit-expanded-object=true]"
                    />
                </th>
                <th><a class="cm-ajax" href="{"`$c_url`&sort_by=name&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.docs_name")}{if $search.sort_by === "name"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="10%" class="mobile-hide"><a class="cm-ajax" href="{"`$c_url`&sort_by=type&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.document_type")}{if $search.sort_by === "type"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="15%"><a class="cm-ajax" href="{"`$c_url`&sort_by=timestamp&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.date_of_creation")}{if $search.sort_by === "timestamp"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="10%" class="mobile-hide"><a class="cm-ajax" href="{"`$c_url`&sort_by=type&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.document_description")}{if $search.sort_by === "description"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="10%" class="mobile-hide"><a class="cm-ajax" href="{"`$c_url`&sort_by=type&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.document_category")}{if $search.sort_by === "category"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>
                <th width="10%" class="mobile-hide"><a class="cm-ajax" href="{"`$c_url`&sort_by=type&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.availability")}{if $search.sort_by === "availability"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</a></th>

                {hook name="docs:manage_header"}
                {/hook}

                <th width="10%" class="right"><a class="cm-ajax" href="{"`$c_url`&sort_by=status&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("docs.status")}{if $search.sort_by === "status"}{$c_icon nofilter}{/if}</a></th>
                <th width="6%" class="mobile-hide">&nbsp;</th>
            </tr>
            </thead>
            {foreach from=$docs item=doc}
            <tr class="cm-row-status-{$doc.status|lower} cm-longtap-target"
                {if $has_permission}
                    data-ca-longtap-action="setCheckBox"
                    data-ca-longtap-target="input.cm-item"
                    data-ca-id="{$doc.docs_id}"
                {/if}
            >
                {$allow_save=$docs|fn_allow_save_object:"docs"}

                {if $allow_save}
                    {$no_hide_input="cm-no-hide-input"}
                {else}
                    {$no_hide_input=""}
                {/if}

                <td width="6%" class="left mobile-hide">
                    <input type="checkbox" name="docs_ids[]" value="{$doc.docs_id}" class="cm-item {$no_hide_input} cm-item-status-{$doc.status|lower} hide" /></td>
                <td class="{$no_hide_input}" data-th="{__("docs.docs")}">
                    <a class="row-status" href="{"docs.update?docs_id=`$doc.docs_id`"|fn_url}">{$doc.name}</a>
                </td>
               
                <td width="15%" data-th="{__("type")}">
                    {if $doc.type == "A"}{__('docs.for_all')}{else}{__('docs.interior')}{/if}
                </td>

                <td width="15%" data-th="{__("creation_date")}">
                    {$doc.timestamp|date_format:"`$settings.Appearance.date_format`, `$settings.Appearance.time_format`"}
                </td>

                <td width="15%" data-th="{__("description")}">
                    {$doc.description}
                </td>

                <td width="15%" data-th="{__("category")}">
                    {if $doc.category == "O"}{__('docs.other')}{else}{__('docs.accounts')}{/if}
                </td>

                <td width="15%" data-th="{__("availability")}">
                    {if $doc.type == "A"}{__('docs.administrators')}, {__('docs.users')}{else}{__('docs.administrators')}{/if}
                </td>

                <td width="10%" class="right" data-th="{__("status")}">
                    {include file="common/select_popup.tpl" id=$doc.docs_id status=$doc.status hidden=true object_id_name="docs_id" table="docs" popup_additional_class="`$no_hide_input` dropleft"}
                </td>
                <td width="6%" class="mobile-hide">
                    {capture name="tools_list"}
                        <li>{btn type="list" text=__("edit") href="docs.update?docs_id=`$doc.docs_id`"}</li>
                    {if $allow_save}
                        <li>{btn type="list" class="cm-confirm" text=__("delete") href="docs.delete?docs_id=`$doc.docs_id`" method="POST"}</li>
                    {/if}
                    {/capture}
                    <div class="hidden-tools">
                        {dropdown content=$smarty.capture.tools_list}
                    </div>
                </td>
            </tr>
            {/foreach}
            </table>
        </div>
    {/capture}

    {include file="common/context_menu_wrapper.tpl"
        form="docs_form"
        object="docs"
        items=$smarty.capture.docs_table
        has_permissions=$has_permission
    }
{else}
    <p class="no-items">{__("no_data")}</p>
{/if}

{include file="common/pagination.tpl" div_id="pagination_contents_docs"}

{capture name="adv_buttons"}
    {include file="common/tools.tpl" tool_href="docs.add" prefix="top" hide_tools="true" title=__("docs.add_document") icon="icon-plus"}
{/capture}

</form>

{/capture}

{capture name="sidebar"}
    {hook name="docs:manage_sidebar"}
    {include file="common/saved_search.tpl" dispatch="docs.manage" view_type="docs"}
    {include file="addons/docs/views/docs/components/docs_search_form.tpl" dispatch="docs.manage"}
    {/hook}
{/capture}

{hook name="docs:manage_mainbox_params"}
    {$page_title = __("docs.docs")}
    {$select_languages = true}
{/hook}

{include file="common/mainbox.tpl" title=$page_title content=$smarty.capture.mainbox adv_buttons=$smarty.capture.adv_buttons select_languages=$select_languages sidebar=$smarty.capture.sidebar}

{** ad section **}
