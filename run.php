<?php declare(strict_types = 1);

require __DIR__ . '/vendor/autoload.php';

use Amp\Postgres;

Amp\Loop::run(function () {
    $config = Postgres\ConnectionConfig::fromString('host=postgres:5432 user=postgres password=postgres');

    /** @var \Amp\Postgres\Connection $connection */
    $connection = yield Postgres\connect($config);

    /** @var \Amp\Postgres\ResultSet $result */
    $result = yield $connection->query('SHOW ALL');

    while (yield $result->advance()) {
        $row = $result->getCurrent();
        \printf("%-35s = %s (%s)\n", $row['name'], $row['setting'], $row['description']);
    }
});
