{include file="sections/header.tpl"}

<style>
    .pagination {
        justify-content: center;
        margin-top: 20px;
    }

    .pagination .page-item .page-link {
        color: #007bff;
        background-color: #fff;
        border: 1px solid #dee2e6;
        margin: 0 2px;
        padding: 6px 12px;
    }

    .pagination .page-item .page-link:hover {
        background-color: #e9ecef;
    }

    .pagination .page-item.active .page-link {
        z-index: 1;
        color: #fff;
        background-color: #007bff;
        border-color: #007bff;
    }

    .pagination-container {
        display: flex;
        justify-content: flex-end;
        margin-top: 20px;
    }

    .badge {
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        border-radius: 4px;
    }

    .badge-danger {
        color: #721c24;
        background-color: #f8d7da;
    }

    .badge-success {
        color: #155724;
        background-color: #d4edda;
    }

    .badge-warning {
        color: #856404;
        background-color: #ffeeba;
    }

    .badge-info {
        color: #0c5460;
        background-color: #d1ecf1;
    }
</style>

<div id="logsys-mikrotik" class="container">
    <table class="table table-bordered table-striped">
        <thead class="thead-dark">
            <tr>
                <th>Waktu</th>
                <th>Topik</th>
                <th>Pesan</th>
            </tr>
        </thead>
        <tbody>
            {assign var=current_page value=$smarty.get.page|default:1}
            {assign var=per_page value=15}
            {assign var=start_index value=($current_page - 1) * $per_page}
            
            {foreach from=$logs item=log name=logLoop}
                {if $smarty.foreach.logLoop.index >= $start_index && $smarty.foreach.logLoop.index < ($start_index + $per_page)}
                    <tr>
                        <td>{$log.time}</td>
                        <td>{$log.topics}</td>
                        <td>
                            {if $log.message|lower|strpos:'failed' !== false}
                                <span class="badge badge-danger">Error</span>
                            {elseif $log.message|lower|strpos:'trying' !== false}
                                <span class="badge badge-warning">Warning</span>
                            {elseif $log.message|lower|strpos:'logged in' !== false}
                                <span class="badge badge-success">Success</span>
                            {elseif $log.message|lower|strpos:'login failed' !== false}
                                <span class="badge badge-info">Login Info</span>
                            {else}
                                <span class="badge badge-info">Info</span>
                            {/if}
                            {$log.message}
                        </td>
                    </tr>
                {/if}
            {/foreach}
        </tbody>
    </table>

    {assign var=total_logs value=$logs|@count}
    {assign var=last_page value=ceil($total_logs / $per_page)}

    <nav aria-label="Page navigation">
        <div class="pagination-container">
            <ul class="pagination">
                {if $current_page > 1}
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page=1" aria-label="First">
                            <span aria-hidden="true">&laquo;&laquo;</span>
                        </a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$current_page-1}" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                            <span class="sr-only">Previous</span>
                        </a>
                    </li>
                {/if}

                {assign var=max_links value=5}

                {assign var=start_page value=max(1, $current_page - floor($max_links / 2))}
                {assign var=end_page value=min($last_page, $start_page + $max_links - 1)}

                {if $start_page > 1}
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$start_page-1}" aria-label="Previous">
                            <span aria-hidden="true">&hellip;</span>
                        </a>
                    </li>
                {/if}

                {foreach from=range($start_page, $end_page) item=page}
                    <li class="page-item {if $page == $current_page}active{/if}">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$page}">
                            {$page}
                        </a>
                    </li>
                {/foreach}

                {if $end_page < $last_page}
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$end_page+1}" aria-label="Next">
                            <span aria-hidden="true">&hellip;</span>
                        </a>
                    </li>
                {/if}

                {if $current_page < $last_page}
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$current_page+1}" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                            <span class="sr-only">Next</span>
                        </a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$last_page}" aria-label="Last">
                            <span aria-hidden="true">&raquo;&raquo;</span>
                        </a>
                    </li>
                {/if}
            </ul>
        </div>
    </nav>
</div>

{include file="sections/footer.tpl"}
