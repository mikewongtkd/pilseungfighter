<?php

class SqliteSessionHandler implements SessionHandlerInterface {
    private $db;
    private $savePath;

    public function open( $savePath, $sessionName ) : bool {
        $this->savePath = $savePath;
        // Open the SQLite database connection
        $this->db = new SQLite3( $this->savePath );
        $this->db->enableExceptions( true ); // Recommended to handle errors properly

        // Create the sessions table if it doesn't exist
        $this->db->exec( "CREATE TABLE IF NOT EXISTS sessions (
            id TEXT NOT NULL PRIMARY KEY,
            data BLOB,
            expires INTEGER
        )" );
        return true;
    }

    public function close() : bool {
        $this->db->close();
        return true;
    }

    public function read( $id ) : string {
        $id = $this->db->escapeString( $id );
        $result = $this->db->query( "SELECT data FROM sessions WHERE id = '{$id}' AND expires > " . time());
        $row = $result->fetchArray( SQLITE3_ASSOC );
        return $row ? $row['data'] : '';
    }

    public function write( $id, $data ) : bool {
        $id = $this->db->escapeString( $id );
        $data = $this->db->escapeString( $data );
        $expires = time() + ini_get( 'session.gc_maxlifetime' );
        // Use REPLACE INTO to handle both inserts and updates
        $sql = "REPLACE INTO sessions (id, data, expires) VALUES ('$id', '$data', $expires)";
        return $this->db->exec( $sql );
    }

    public function destroy( $id ) : bool {
        $id = $this->db->escapeString( $id );
        $this->db->exec( "DELETE FROM sessions WHERE id = '$id'" );
        return true;
    }

    public function gc( $max_lifetime ) : int|false {
        $this->db->exec( "DELETE FROM sessions WHERE expires < " . time());
        return true;
    }
}

// Set the path where the session database file will be stored
ini_set( 'session.save_path', '/usr/local/psf/psf.sqlite' ); // Use an absolute path

// Instantiate and register the custom handler
$handler = new SqliteSessionHandler();
session_set_save_handler( $handler, true ); // The 'true' registers a shutdown function to write session data

// Start the session
session_name( 'psf-session' );
session_start();

?>
