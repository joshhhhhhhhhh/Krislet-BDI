//
//	File:			Memory.java
//	Author:		Krzysztof Langner
//	Date:			1997/04/28
//

package krislet;

import java.util.Collections;
import java.util.Vector;

public class Memory
{
	private VisualInfo info;	// place where all information is stored
	private final Object infoLock;

    //---------------------------------------------------------------------------
    // This constructor:
    // - initializes all variables
    public Memory()
    {
		infoLock = new Object();
	}


    //---------------------------------------------------------------------------
    // This function puts see information into our memory
    public void store(VisualInfo info)
    {
		synchronized (this.infoLock) {
			this.info = info;
			this.infoLock.notifyAll();
		}
    }

    //---------------------------------------------------------------------------
    // This function looks for specified object
    public ObjectInfo getObject(String name) {
		synchronized (this.infoLock) {
			if (this.info == null) {
				return null;
			}

			for(int c = 0; c < this.info.m_objects.size() ; c ++) {
				ObjectInfo object = this.info.m_objects.elementAt(c);
				if(object.m_type.compareTo(name) == 0) {
					return object;
				}
			}
		}

		return null;
    }

	public Vector<?> getFlagList() {
		if (info == null) {
			return new Vector<>();
		}

		return info.getFlagList();
	}

	public Vector<?> getPlayerList() {
		if (info == null) {
			return new Vector<>();
		}

		return info.getPlayerList();
	}

    //---------------------------------------------------------------------------
    // This function waits for new visual information
    public void waitForNewInfo() throws InterruptedException {
		synchronized (infoLock) {
			info.wait();
		}
    }
}

