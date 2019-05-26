package com.newcmms.newcmms_flutter

import android.nfc.cardemulation.HostApduService
import android.os.Bundle

class NfcTextNdefHceService : HostApduService() {
    companion object {
        private val APDU_SELECT = byteArrayOf(
                0x00.toByte(), // CLA	- Class - Class of instruction
                0xA4.toByte(), // INS	- Instruction - Instruction code
                0x04.toByte(), // P1	- Parameter 1 - Instruction parameter 1
                0x00.toByte(), // P2	- Parameter 2 - Instruction parameter 2
                0x07.toByte(), // Lc field	- Number of bytes present in the data field of the command
                0xD2.toByte(), 0x76.toByte(), 0x00.toByte(), 0x00.toByte(), 0x85.toByte(), 0x01.toByte(), 0x01.toByte(), // NDEF Tag Application name
                0x00.toByte()  // Le field	- Maximum number of bytes expected in the data field of the response to the command
        )

        private val CAPABILITY_CONTAINER_OK = byteArrayOf(
                0x00.toByte(), // CLA	- Class - Class of instruction
                0xa4.toByte(), // INS	- Instruction - Instruction code
                0x00.toByte(), // P1	- Parameter 1 - Instruction parameter 1
                0x0c.toByte(), // P2	- Parameter 2 - Instruction parameter 2
                0x02.toByte(), // Lc field	- Number of bytes present in the data field of the command
                0xe1.toByte(), 0x03.toByte() // file identifier of the CC file
        )

        private val A_OKAY = byteArrayOf(
                0x90.toByte(), // SW1	Status byte 1 - Command processing status
                0x00.toByte()   // SW2	Status byte 2 - Command processing qualifier
        )

        private val A_ERROR = byteArrayOf(
                0x6A.toByte(), // SW1	Status byte 1 - Command processing status
                0x82.toByte()   // SW2	Status byte 2 - Command processing qualifier
        )
    }

    private var _stringValue: String = ""

    var stringValue: String
        get() = _stringValue
        set(value) {
            _stringValue = value;
        }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onDeactivated(reason: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }
}