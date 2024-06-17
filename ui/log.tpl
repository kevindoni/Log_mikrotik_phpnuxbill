{include file="sections/header.tpl"}
    <form class="form-horizontal" method="post" role="form" action="{$_url}plugin/log_ui">
      <ul class="nav nav-tabs"> {foreach $routers as $r} <li role="presentation" {if $r['id']==$router}class="active" {/if}>
          <a href="{$_url}plugin/log_ui/{$r['id']}">{$r['name']}</a>
        </li> {/foreach} </ul>
    </form>
<style>
    /* Styles for overall layout and responsiveness */
    body {
        background-color: #f8f9fa;
        font-family: 'Arial', sans-serif;
    }
    .container {
        margin-top: 20px;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        padding: 20px;
    }
    /* Styles for table and pagination */
    .table {
        width: 100%;
        margin-bottom: 1rem;
        background-color: #fff;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    .table th {
        vertical-align: middle;
        border-color: #dee2e6;
        background-color: #343a40;
        color: #fff;
    }
    .table td {
        vertical-align: middle;
        border-color: #dee2e6;
    }
    .table-striped tbody tr:nth-of-type(odd) {
        background-color: rgba(0, 0, 0, 0.05);
    }
    .dataTables_length, .dataTables_filter {
        margin-bottom: 20px;
    }
    .form-control {
        border-radius: 4px;
    }
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
        transition: background-color 0.3s, color 0.3s;
    }
    .pagination .page-item .page-link:hover {
        background-color: #e9ecef;
        color: #0056b3;
    }
    .pagination .page-item.active .page-link {
        z-index: 1;
        color: #fff;
        background-color: #007bff;
        border-color: #007bff;
    }
    .pagination-container {
        display: flex;
        justify-content: center;
        margin-top: 20px;
    }
    /* Styles for log message badges */
    .badge {
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        border-radius: 4px;
        transition: background-color 0.3s, color 0.3s;
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
    .badge:hover {
        opacity: 0.8;
    }
</style>

<div id="logsys-mikrotik" class="container">
    <div class="row">
        <div class="col-sm-4 col-md-10">
            <div class="dataTables_length" id="data_length">
                <label>Show entries
                    <select name="data_length" aria-controls="data" class="custom-select custom-select-sm form-control form-control-sm" onchange="updatePerPage(this.value)">
                        <option value="5" {if $per_page == 5}selected{/if}>5</option>
                        <option value="10" {if $per_page == 10}selected{/if}>10</option>
                        <option value="25" {if $per_page == 25}selected{/if}>25</option>
                        <option value="50" {if $per_page == 50}selected{/if}>50</option>
                        <option value="100" {if $per_page == 100}selected{/if}>100</option>
                    </select>
                </label>
            </div>
        </div>
        <div class="col-sm-2 col-md-2">
            <div id="data_filter" class="dataTables_filter">
                <label>Search:<input type="search" id="logSearch" class="form-control form-control-sm" placeholder="" aria-controls="data" onkeyup="filterLogs()"></label>
            </div>
        </div>
    </div>

    <table class="table table-bordered table-striped">
        <thead class="thead-dark">
            <tr>
                <th>Waktu</th>
                <th>Topik</th>
                <th>Pesan</th>
            </tr>
        </thead>
        <tbody id="logTableBody">
            {assign var=current_page value=$smarty.get.page|default:1}
            {assign var=per_page value=$smarty.get.per_page|default:10}
            {assign var=start_index value=($current_page - 1) * $per_page}
            
            {foreach from=$logs|array_reverse item=log name=logLoop}
                {if $smarty.foreach.logLoop.index >= $start_index && $smarty.foreach.logLoop.index < ($start_index + $per_page)}
                    <tr class="log-entry">
                        <td>{$log.time}</td>
                        <td>{$log.topics}</td>
                        <td class="log-message">
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
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page=1&per_page={$per_page}" aria-label="First">
                            <span aria-hidden="true">&laquo;&laquo;</span>
                        </a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$current_page-1}&per_page={$per_page}" aria-label="Previous">
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
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$start_page-1}&per_page={$per_page}" aria-label="Previous">
                            <span aria-hidden="true">&hellip;</span>
                        </a>
                    </li>
                {/if}

                {foreach from=range($start_page, $end_page) item=page}
                    <li class="page-item {if $page == $current_page}active{/if}">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$page}&per_page={$per_page}">
                            {$page}
                        </a>
                    </li>
                {/foreach}

                {if $end_page < $last_page}
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$end_page+1}&per_page={$per_page}" aria-label="Next">
                            <span aria-hidden="true">&hellip;</span>
                        </a>
                    </li>
                {/if}

                {if $current_page < $last_page}
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$current_page+1}&per_page={$per_page}" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                            <span class="sr-only">Next</span>
                        </a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="index.php?_route=plugin/log_ui&page={$last_page}&per_page={$per_page}" aria-label="Last">
                            <span aria-hidden="true">&raquo;&raquo;</span>
                        </a>
                    </li>
                {/if}
            </ul>
        </div>
    </nav>
</div>

<script>
  window.addEventListener('DOMContentLoaded', function() {
    var portalLink = "https://github.com/kevindoni";
    $('#version').html('Log Mikrotik | Ver: 1.0 | by: <a href="' + portalLink + '">Kevin Doni</a>');
  });

  function updatePerPage(value) {
    var urlParams = new URLSearchParams(window.location.search);
    urlParams.set('per_page', value);
    urlParams.set('page', 1); // Reset to first page
    window.location.search = urlParams.toString();
  }

  function filterLogs() {
    var input = document.getElementById('logSearch').value.toLowerCase();
    var table = document.getElementById('logTableBody');
    var tr = table.getElementsByClassName('log-entry');

    for (var i = 0; i < tr.length; i++) {
      var logMessage = tr[i].getElementsByClassName('log-message')[0].textContent || tr[i].getElementsByClassName('log-message')[0].innerText;
      if (logMessage.toLowerCase().indexOf(input) > -1) {
        tr[i].style.display = '';
      } else {
        tr[i].style.display = 'none';
      }
    }
  }
</script>

{include file="sections/footer.tpl"}
